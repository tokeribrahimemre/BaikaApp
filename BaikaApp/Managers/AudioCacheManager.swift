//
//  AudioCacheManager.swift
//  BaikaApp
//
//  Created by İbrahim Emre Toker on 9.04.2026.
//

import Foundation
import CommonCrypto

/// Cihaz üzerinde ses dosyalarını disk cache olarak yönetir.
/// Aynı metin + ses kombinasyonu için aynı hash üretir ve dosyayı saklar.
/// Belirli süre (varsayılan 7 gün) sonra eski dosyaları temizler.
final class AudioCacheManager {
    
    static let shared = AudioCacheManager()
    
    /// Cache'in geçerlilik süresi (saniye cinsinden, varsayılan 7 gün)
    private let cacheExpiration: TimeInterval = 7 * 24 * 60 * 60
    
    /// Cache dizini
    private let cacheDirectory: URL
    
    private init() {
        let cachesDir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        cacheDirectory = cachesDir.appendingPathComponent("TTSAudioCache", isDirectory: true)
        
        // Dizin yoksa oluştur
        if !FileManager.default.fileExists(atPath: cacheDirectory.path) {
            try? FileManager.default.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
        }
        
        // Uygulama başlarken süresi geçmiş dosyaları temizle
        cleanExpiredFiles()
    }
    
    // MARK: - Public API
    
    /// Metin + ses adına göre cache'de ses var mı kontrol eder
    func cachedAudioData(for text: String, voiceName: String) -> Data? {
        let fileURL = fileURL(for: text, voiceName: voiceName)
        
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return nil
        }
        
        // Dosya süresi dolmuş mu kontrol et
        if isFileExpired(at: fileURL) {
            try? FileManager.default.removeItem(at: fileURL)
            return nil
        }
        
        return try? Data(contentsOf: fileURL)
    }
    
    /// Ses verisini diske kaydet
    func cacheAudioData(_ data: Data, for text: String, voiceName: String) {
        let fileURL = fileURL(for: text, voiceName: voiceName)
        try? data.write(to: fileURL)
    }
    
    /// Tüm cache'i temizle
    func clearAllCache() {
        try? FileManager.default.removeItem(at: cacheDirectory)
        try? FileManager.default.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
    }
    
    /// Cache boyutunu döndür (byte cinsinden)
    var totalCacheSize: Int64 {
        guard let files = try? FileManager.default.contentsOfDirectory(
            at: cacheDirectory,
            includingPropertiesForKeys: [.fileSizeKey],
            options: .skipsHiddenFiles
        ) else { return 0 }
        
        return files.reduce(0) { total, fileURL in
            let size = (try? fileURL.resourceValues(forKeys: [.fileSizeKey]).fileSize) ?? 0
            return total + Int64(size)
        }
    }
    
    /// Cache boyutunu okunabilir formatta döndür (ör: "12.3 MB")
    var formattedCacheSize: String {
        let bytes = totalCacheSize
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useMB, .useKB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }
    
    // MARK: - Private
    
    /// Metin + ses adından benzersiz dosya adı üretir (SHA-256 hash)
    func generateHash(text: String, voiceName: String) -> String {
        let input = "\(voiceName)::\(text)"
        guard let data = input.data(using: .utf8) else { return UUID().uuidString }
        
        var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        data.withUnsafeBytes { buffer in
            _ = CC_SHA256(buffer.baseAddress, CC_LONG(buffer.count), &hash)
        }
        return hash.map { String(format: "%02x", $0) }.joined()
    }
    
    /// Hash'e göre dosya URL'si
    private func fileURL(for text: String, voiceName: String) -> URL {
        let hash = generateHash(text: text, voiceName: voiceName)
        return cacheDirectory.appendingPathComponent("\(hash).mp3")
    }
    
    /// Dosyanın süresi dolmuş mu kontrol et
    private func isFileExpired(at url: URL) -> Bool {
        guard let attributes = try? FileManager.default.attributesOfItem(atPath: url.path),
              let modificationDate = attributes[.modificationDate] as? Date else {
            return true
        }
        return Date().timeIntervalSince(modificationDate) > cacheExpiration
    }
    
    /// Süresi dolmuş dosyaları temizle
    private func cleanExpiredFiles() {
        DispatchQueue.global(qos: .utility).async { [weak self] in
            guard let self = self else { return }
            guard let files = try? FileManager.default.contentsOfDirectory(
                at: self.cacheDirectory,
                includingPropertiesForKeys: [.contentModificationDateKey],
                options: .skipsHiddenFiles
            ) else { return }
            
            for fileURL in files {
                if self.isFileExpired(at: fileURL) {
                    try? FileManager.default.removeItem(at: fileURL)
                }
            }
        }
    }
}
