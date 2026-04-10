const { onCall, HttpsError } = require("firebase-functions/v2/https");
const admin = require("firebase-admin");
const textToSpeech = require("@google-cloud/text-to-speech");
const crypto = require("crypto");
const { GoogleAuth } = require("google-auth-library");

admin.initializeApp();
const bucket = admin.storage().bucket();
const db = admin.firestore();
const auth = new GoogleAuth({ scopes: ["https://www.googleapis.com/auth/cloud-platform"] });
const ttsClient = new textToSpeech.TextToSpeechClient();

const TTS_PROMPT = `Sanki 5 yaşında bir çocuğun başucunda oturuyormuşsun gibi sıcak, nazik ve şefkatli bir tonda oku. 
Kelimeleri tane tane telaffuz et. Hikayenin heyecanlı yerlerinde ses tonunu biraz yükseltip hızlan, 
gizemli veya huzurlu yerlerinde ise yavaşlayıp sesini hafifçe alçalt (fısıltıya yakın). 
Türkçe vurgularına ve duraklamalarına dikkat ederek masalsı bir atmosfer yarat.`;

// Gemini TTS modelName → fallback standard ses eşlemesi
const GEMINI_TO_STANDARD = {
    "Kore":     { name: "tr-TR-Journey-F", languageCode: "tr-TR" },
    "Achernar": { name: "tr-TR-Journey-D", languageCode: "tr-TR" },
    "Leda":     { name: "tr-TR-Standard-A", languageCode: "tr-TR" },
    "Orus":     { name: "tr-TR-Standard-B", languageCode: "tr-TR" },
    "Zephyr":   { name: "tr-TR-Standard-C", languageCode: "tr-TR" },
};

function generateAudioHash(text, voiceName, modelName) {
    return crypto.createHash("sha256").update(`${modelName}::${voiceName}::${text}`).digest("hex");
}

/**
 * Gemini TTS v1beta1 ile ses dener, başarısız olursa Journey/Standard TTS'e fallback yapar.
 */
async function synthesizeAndUpload(text, voiceName, modelName, storagePath) {
    let audioContent = null;

    // 1) Gemini TTS dene
    try {
        const client = await auth.getClient();
        const accessToken = await client.getAccessToken();

        const ttsBody = {
            input: { text, prompt: TTS_PROMPT },
            voice: { languageCode: "tr-TR", name: voiceName, modelName },
            audioConfig: { audioEncoding: "MP3", speakingRate: 1, sampleRateHertz: 24000 },
        };

        const ttsResponse = await fetch(
            "https://texttospeech.googleapis.com/v1beta1/text:synthesize",
            {
                method: "POST",
                headers: {
                    "Authorization": `Bearer ${accessToken.token}`,
                    "Content-Type": "application/json",
                },
                body: JSON.stringify(ttsBody),
            }
        );

        if (ttsResponse.ok) {
            const ttsResult = await ttsResponse.json();
            if (ttsResult.audioContent && ttsResult.audioContent.length > 100) {
                audioContent = Buffer.from(ttsResult.audioContent, "base64");
                console.log(`✅ Gemini TTS başarılı: ${voiceName}, ${audioContent.length} bytes`);
            } else {
                const body = JSON.stringify(ttsResult);
                console.warn(`⚠️ Gemini TTS boş/geçersiz yanıt (${voiceName}): ${body.substring(0, 200)}`);
            }
        } else {
            const errorText = await ttsResponse.text();
            console.warn(`⚠️ Gemini TTS HTTP ${ttsResponse.status} (${voiceName}): ${errorText.substring(0, 300)}`);
        }
    } catch (geminiErr) {
        console.warn(`⚠️ Gemini TTS exception (${voiceName}): ${geminiErr.message}`);
    }

    // 2) Gemini başarısız → Journey/Standard TTS fallback
    if (!audioContent) {
        const fallback = GEMINI_TO_STANDARD[voiceName] || { name: "tr-TR-Journey-F", languageCode: "tr-TR" };
        console.log(`🔄 Fallback: ${voiceName} → ${fallback.name}`);

        const [response] = await ttsClient.synthesizeSpeech({
            input: { text },
            voice: { languageCode: fallback.languageCode, name: fallback.name },
            audioConfig: {
                audioEncoding: "MP3",
                speakingRate: 0.9,
                pitch: 1.5,
            },
        });
        audioContent = response.audioContent;
        console.log(`✅ Fallback TTS başarılı: ${fallback.name}, ${audioContent.length} bytes`);
    }

    // 3) Storage'a yükle
    const file = bucket.file(storagePath);
    await file.save(audioContent, {
        metadata: {
            contentType: "audio/mpeg",
            metadata: { voiceName, modelName, createdAt: new Date().toISOString() },
        },
    });

    const [url] = await file.getSignedUrl({
        action: "read",
        expires: Date.now() + 7 * 24 * 60 * 60 * 1000,
    });

    return url;
}

exports.generateStoryAudio = onCall({
    region: "us-central1",
    timeoutSeconds: 540,
    memory: "1GiB"
}, async (request) => {
    const text = request.data.text;
    const voiceName = request.data.voiceName || "Kore";
    const modelName = request.data.modelName || "gemini-2.5-flash-tts";
    const storyID = request.data.storyID || null;
    const chunkIndex = request.data.chunkIndex != null ? request.data.chunkIndex : null;

    if (!text || text.length === 0) {
        throw new HttpsError("invalid-argument", "Masal metni boş olamaz!");
    }

    try {
        // ── Firestore hikayesi chunk'ı ise: soundURLs.{voiceName}_chunk{N} üzerinden cache ──
        if (storyID) {
            const chunkKey = chunkIndex != null ? `${voiceName}_chunk${chunkIndex}` : voiceName;
            const storagePath = chunkIndex != null
                ? `tts_stories/${storyID}/${voiceName}_chunk${chunkIndex}.mp3`
                : `tts_stories/${storyID}/${voiceName}.mp3`;

            const storyRef = db.collection("stories").doc(storyID);
            const storyDoc = await storyRef.get();

            if (storyDoc.exists) {
                const soundURLs = storyDoc.data().soundURLs || {};
                if (soundURLs[chunkKey]) {
                    const [exists] = await bucket.file(storagePath).exists();
                    if (exists) {
                        const [freshURL] = await bucket.file(storagePath).getSignedUrl({
                            action: "read",
                            expires: Date.now() + 7 * 24 * 60 * 60 * 1000,
                        });
                        await storyRef.update({ [`soundURLs.${chunkKey}`]: freshURL });
                        console.log(`Story chunk cache hit: ${storyID}/${chunkKey}`);
                        return { audioURL: freshURL };
                    }
                }
            }

            // Cache yok → üret
            const url = await synthesizeAndUpload(text, voiceName, modelName, storagePath);
            await storyRef.set({ soundURLs: { [chunkKey]: url } }, { merge: true });
            console.log(`Story chunk üretildi: ${storyID}/${chunkKey}`);
            return { audioURL: url };
        }

        // ── Firestore hikayesi değil (AI oluşturulan) → hash-based Storage cache ──
        const hash = generateAudioHash(text, voiceName, modelName);
        const filePath = `tts_audio/${hash}.mp3`;
        const file = bucket.file(filePath);

        const [exists] = await file.exists();
        if (exists) {
            const [url] = await file.getSignedUrl({
                action: "read",
                expires: Date.now() + 7 * 24 * 60 * 60 * 1000,
            });
            console.log("Hash cache hit:", filePath);
            return { audioURL: url };
        }

        const url = await synthesizeAndUpload(text, voiceName, modelName, filePath);
        console.log("Hash cache miss, yeni ses oluşturuldu:", filePath);
        return { audioURL: url };
    } catch (error) {
        if (error instanceof HttpsError) throw error;
        console.error("Ses oluşturulurken hata:", error);
        throw new HttpsError("internal", `Ses oluşturulamadı: ${error.message}`);
    }
});
