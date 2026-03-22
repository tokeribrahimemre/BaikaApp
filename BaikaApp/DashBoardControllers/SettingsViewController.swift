import FirebaseFirestore

import UIKit

class SettingsViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        uploadMockDataToFirebase()
        // Do any additional setup after loading the view.
    }
    
    func uploadMockDataToFirebase() {
        let db = Firestore.firestore()
        
        let storiesToUpload: [Story] = [
            Story(
                id: "1", dictionary: [
                    "time": "5 dk",
                    "title": "Kara Başlıklı Kız",
                    "description": """
                Bir zamanlar, ormanın hemen kenarındaki sevimli bir kulübede yaşayan tatlı bir kız varmış. Büyükannesi onu o kadar çok severmiş ki, ona kendi elleriyle kırmızı kadifeden pelerinli bir başlık dikmiş. Kız bu başlığı o kadar sevmiş ki hiç çıkarmamış, bu yüzden herkes ona 'Kırmızı Başlıklı Kız' demeye başlamış.
                
                Güneşli bir ilkbahar sabahı, annesi onu yanına çağırmış. "Kırmızı Başlıklı Kız, büyükannen biraz hasta olmuş. Ona kendi yaptığım taze çöreklerden ve bir şişe meyve suyundan hazırladım. Lütfen bunları ona götür ama orman yolundan sakın ayrılma, oyalanma ve yabancılarla konuşma," diye tembihlemiş. Kırmızı Başlıklı Kız sepetini koluna takmış ve annesine söz vererek yola koyulmuş.
                
                Ormanın içi rengarenk çiçekler, cıvıl cıvıl öten kuşlarla doluymuş. Kırmızı Başlıklı Kız, büyükannesine güzel bir buket yapmak için yolun kenarındaki çiçekleri toplamaya dalmış. O sırada kurnaz bir kurt onu ağaçların arkasından izliyormuş. Kurt, kızın yanına yaklaşıp nazikçe "Nereye gidiyorsun küçük kız?" diye sormuş. Kırmızı Başlıklı Kız, annesinin sözünü unutup "Büyükanneme gidiyorum, ormanın sonundaki üç büyük meşe ağacının altındaki evde oturuyor," demiş.
                
                Bunu duyan kurt hızla oradan uzaklaşmış ve kestirme yoldan büyükannenin evine varmış. Olan biteni anlayan bir oduncu ise kurdun peşine düşmüş. Kırmızı Başlıklı Kız eve vardığında kurdun oyununu fark etmiş, tam o sırada oduncu içeri girip kurnaz kurdu ormandan çok uzaklara kovalamış. Büyükannesi ve Kırmızı Başlıklı Kız, oduncuya teşekkür edip taze çörekleri afiyetle yemişler. Kırmızı Başlıklı Kız bir daha annesinin sözünden hiç çıkmamış.
                """,
                    "imageURL": "red_hood_bg",
                    "ageCategory": "5-6 Yaş",
                    "themeCategory": "İyilik"
                ])
//            ),
//            Story(
//                id: "2", dictionary: [
//                    "time": "4 dk",
//                    "title": "Çirkin Ördek Yavrusu",
//                    "description": """
//                Güneşli ve sıcak bir yaz günü, göl kenarındaki sazlıkların arasında anne ördek heyecanla yumurtalarının üzerinde oturuyormuş. Sonunda yumurtalar "çıt çıt" diye çatlamaya başlamış. İçlerinden sarı, minik, sevimli ördek yavruları çıkmış. Fakat en büyük yumurta bir türlü çatlamıyormuş.
//                
//                Uzun bir bekleyişten sonra o büyük yumurta da kırılmış. Ama içinden çıkan yavru diğerlerine hiç benzemiyormuş. Tüyleri gri, boynu uzun ve sesi de çok tuhafmış. Çiftlikteki diğer hayvanlar bu yavruyu görünce onunla alay etmeye başlamışlar. "Ne kadar da çirkin bir ördek yavrusu!" diyerek ona gülmüşler. Zavallı yavru çok üzülmüş ve her gün gölün en tenha köşesinde tek başınaymış.
//                
//                Günler haftaları, haftalar ayları kovalamış ve kış gelmiş. Soğuk kış günlerini zorlukla atlatan yavru ördek, ilkbaharın gelmesiyle sıcak güneşin tadını çıkarmak için göle doğru yüzmüş. Suyun üzerinde süzülen çok güzel, bembeyaz kuşlar görmüş. Bunlar kuğularmış. Utanarak yanlarına yaklaşmış ve "Benim gibi çirkin birini aranıza alır mısınız?" diye sormuş. 
//                
//                Kuğular gülümsemiş ve "Sen çirkin değilsin ki, suya bak," demişler. Ördek yavrusu suya eğilip kendi yansımasına baktığında gözlerine inanamamış. O artık gri, çirkin bir ördek yavrusu değil, bembeyaz tüyleriyle gölün en güzel, en zarif kuğularından biriymiş! Kendine olan güveni yerine gelmiş ve yeni arkadaşlarıyla gölün üzerinde mutlulukla süzülmüş.
//                """,
//                    "imageURL": "duckling_bg",
//                    "ageCategory": "3-4 Yas",
//                    "themeCategory": "Arkadaslik"
//                ]
//            ),
//            Story(
//                id: "3", dictionary: [
//                    "time": "3 dk",
//                    "title": "Aslan ile Fare",
//                    "description": """
//                Sıcak bir orman gününde, ormanların kralı koca aslan büyük bir ağacın gölgesinde derin bir uykuya dalmış. Horlaması ormanın her yerinden duyuluyormuş. O sırada ormanda gezinen minik bir fare, etrafta koşuştururken yanlışlıkla uyuyan aslanın kuyruğuna basmış ve aslanın burnunun üzerine düşmüş.
//                
//                Aslan kükreyerek uyanmış ve dev pençesiyle minik fareyi yakalamış. Fare korkuyla titreyerek, "Lütfen sayın kralım, beni affedin! Eğer canımı bağışlarsanız, belki bir gün benim de size bir iyiliğim dokunur," diye yalvarmış. Aslan bu minicik farenin kendisine nasıl yardım edebileceğini düşünüp kahkahalarla gülmüş. Ama farenin çaresizliğine acıyıp onu serbest bırakmış.
//                
//                Aradan aylar geçmiş. Bir gün aslan ormanda avlanırken, avcıların kurduğu büyük bir ağa yakalanmış. Ne kadar kükreyip çırpınsa da dev iplerden kurtulamamış. Aslanın kükremesini duyan minik fare, sesi tanımış ve hızla o yöne koşmuş. Aslanı ağın içinde çaresizce yatarken bulmuş.
//                
//                Fare hemen keskin dişleriyle ağın kalın iplerini kemirmeye başlamış. Uzun bir uğraştan sonra ipleri koparmayı başarmış ve aslanı kurtarmış. Aslan mahçup bir şekilde farenin yüzüne bakmış. "Haklıydın küçük dostum," demiş, "Bir canlının küçüklüğü ya da büyüklüğü önemli değilmiş, iyilik her zaman iyilik getirirmiş." O günden sonra ormanın en büyük kralı ile en küçük faresi en iyi iki arkadaş olmuşlar.
//                """,
//                    "imageURL": "lion_mouse_bg",
//                    "ageCategory": "0-2 Yas",
//                    "themeCategory": "Arkadaslik"
//                ]
//            ),
//            Story(
//                id: "4", dictionary: [
//                    "time": "6 dk",
//                    "title": "Uyuyan Güzel",
//                    "description": """
//                Çok uzak bir krallıkta, kral ve kraliçenin yıllardır bekledikleri kızları dünyaya gelmiş. Bebeğe Aurora adını vermişler ve sarayda büyük bir şölen düzenlemişler. Krallığın tüm perileri bebeğe hediye vermek için davet edilmiş. Periler bebeğe güzellik, iyilik ve güzel ses hediye etmişler.
//                
//                Tam son peri hediyesini verecekken, davet edilmediği için çok öfkelenen kötü kalpli peri Malefiz saraya fırtına gibi girmiş. "Ben de bu bebeğe bir hediye veriyorum!" diye bağırmış. "Aurora on altı yaşına bastığı gün, parmağına bir çıkrık iğnesi batacak ve sonsuz bir uykuya dalacak!" demiş ve ortadan kaybolmuş. Son peri bu laneti tamamen bozamasa da hafifletmiş: "Prenses ölmeyecek, sadece gerçek sevginin öpücüğüyle uyanabileceği yüz yıllık bir uykuya dalacak."
//                
//                Kral korkuyla ülkedeki tüm iğneleri yaktırmış. Ancak prenses 16 yaşına geldiğinde, sarayın eski bir kulesinde gizlice dikiş diken yaşlı bir kadın bulmuş. İğneyi merakla eline aldığında parmağına batmış ve prenses o anda derin bir uykuya dalmış. İyi periler, prenses uyandığında yalnız kalmasın diye tüm saray halkını da uyutmuşlar. Sarayın etrafını devasa dikenli sarmaşıklar sarmış.
//                
//                Yüz yıl sonra, cesur bir prens bu sarayın efsanesini duymuş ve dikenleri kılıcıyla aşarak içeri girmiş. En yüksek kulede uyuyan güzeller güzeli prensesi görünce ona hayran kalmış. Prensesin elini nazikçe tutup alnına bir öpücük kondurmuş. O anda büyü bozulmuş! Prenses gözlerini açmış, tüm saray halkı uyanmış ve kuşlar tekrar ötmeye başlamış. Prenses ve prens bir ömür boyu mutlu yaşamışlar.
//                """,
//                    "imageURL": "sleeping_beauty_bg",
//                    "ageCategory": "3-4 Yas",
//                    "themeCategory": "Uyku"
//                ]
//            ),
//            Story(
//                id: "5", dictionary: [
//                    "time": "5 dk",
//                    "title": "Üç Küçük Domuzcuk",
//                    "description": """
//                Bir zamanlar, artık büyüdükleri için kendi evlerini yapmaları gereken üç küçük domuzcuk varmış. Annelerine veda edip ormana doğru yola çıkmışlar. 
//                
//                Birinci domuzcuk çok tembelmiş. Hemen oynamak istediği için kendisine samandan çok hafif bir ev yapmış. Ev bir günde bitmiş ve bütün gün şarkı söyleyerek eğlenmiş.
//                
//                İkinci domuzcuk biraz daha çalışkanmış ama o da oyun oynamayı çok seviyormuş. Kendisine tahtadan ve dallardan bir ev yapmış. İki gün süren inşaattan sonra o da kardeşinin yanına oyun oynamaya gitmiş.
//                
//                Üçüncü domuzcuk ise en akıllıları ve en çalışkanlarıymış. Günlerce uğraşıp, ağır tuğlaları üst üste dizerek, çimentoyla sağlam bir ev yapmış. Kardeşleri "Gel bizimle oyna, neden bu kadar yoruluyorsun?" diye onunla dalga geçmişler ama o evini bitirene kadar çalışmış.
//                
//                Bir gün ormana aç ve kötü bir kurt gelmiş. Önce samandan evin kapısını çalmış. Domuzcuk kapıyı açmayınca kurt derin bir nefes almış ve "Üflerim, püflerim, bu evi yıkarım!" demiş. Saman ev bir anda uçup gitmiş! Birinci domuzcuk kaçarak tahta eve sığınmış.
//                
//                Kurt tahta evin önüne gelmiş. Yine derin bir nefes alıp "Üflerim, püflerim, bu evi yıkarım!" demiş. Tahta ev de çıtırdamış ve yıkılmış. İki kardeş ağlayarak tuğla eve, üçüncü domuzcuğun yanına kaçmışlar. Kurt tuğla evin önüne gelmiş, günlerce üflemiş, püflemiş ama ev o kadar sağlammış ki yerinden bile oynamamış. Yorulan kurt pes edip ormanı terk etmiş. Üç kardeş o günden sonra çalışmanın ne kadar önemli olduğunu anlamışlar.
//                """,
//                    "imageURL": "three_pigs_bg",
//                    "ageCategory": "3-4 Yas",
//                    "themeCategory": "Macera"
//                ]
//            ),
//            Story(
//                id: "6", dictionary: [
//                    "time": "3 dk",
//                    "title": "Tavşan ile Kaplumbağa",
//                    "description": """
//                Geniş ve yeşil bir ormanda, her zaman ne kadar hızlı koştuğuyla övünen, çok kibirli bir tavşan yaşarmış. Her sabah ormandaki hayvanların yanına gider, "Benden daha hızlısı yok, rüzgarı bile geçerim!" diye böbürlenirmiş.
//                
//                Ormanın en bilge ve en sakin hayvanı olan kaplumbağa, tavşanın bu kibrinden çok sıkılmış. Bir gün tavşanın yanına gidip "Eğer bu kadar hızlıysan, seninle bir yarış yapalım. Bakalım tepedeki ulu çınara ilk kim varacak?" demiş. Tavşan kahkahalar atarak bu teklifi kabul etmiş. 
//                
//                Yarış başlamış. Tavşan bir ok gibi fırlamış ve saniyeler içinde gözden kaybolmuş. Kaplumbağa ise kendi yavaş ama emin adımlarıyla yürümeye başlamış. Tavşan yolun yarısına geldiğinde arkasına bakmış, kaplumbağa ufukta bile görünmüyormuş. "Nasıl olsa bu yavaş kaplumbağa akşama kadar buraya gelemez. Şu ağacın altında biraz uyuyayım," demiş ve derin bir uykuya dalmış.
//                
//                Kaplumbağa hiç durmamış. Yorulmuş, terlemiş ama vazgeçmemiş. Adım adım, yavaş yavaş tavşanın uyuduğu ağacı geçmiş ve bitiş çizgisine doğru ilerlemiş. Tavşan saatler sonra uyanıp gerinerek bitiş çizgisine doğru koştuğunda, gözlerine inanamamış. Kaplumbağa ulu çınara çoktan varmış ve yarışı kazanmış! Ormandaki herkes kaplumbağayı alkışlarken, tavşan kibrinin ona yarışı kaybettirdiğini anlamış ve bir daha hiç böbürlenmemiş.
//                """,
//                    "imageURL": "turtle_rabbit_bg",
//                    "ageCategory": "0-2 Yas",
//                    "themeCategory": "Macera"
//                ]
//            ),
//            Story(
//                id: "7", dictionary: [
//                    "time": "6 dk",
//                    "title": "Bremen Mızıkacıları",
//                    "description": """
//                Bir zamanlar, yıllarca sahibinin un çuvallarını taşıyan ama artık yaşlandığı için istenmeyen bir eşek varmış. Sahibinin onu çiftlikten göndereceğini anlayınca evden kaçmış. Aklına harika bir fikir gelmiş; Bremen şehrine gidip orada şehir bandosuna katılacak ve müzisyen olacakmış.
//                
//                Yolda giderken, avlanamayacak kadar yaşlandığı için sokağa atılan üzgün bir av köpeğiyle karşılaşmış. Eşek, "Benimle Bremen'e gel, harika bir müzik grubu kurarız!" demiş. Köpek bu fikri çok sevmiş. Biraz daha yürüdüklerinde fare yakalayamadığı için evden kovulan bir kedi ve kesilmekten son anda kurtulan bir horozla karşılaşmışlar. Dört dışlanmış arkadaş, Bremen'e doğru neşeyle yola koyulmuşlar.
//                
//                Akşam olduğunda yorulmuşlar ve ormanın derinliklerinde ışığı yanan küçük bir kulübe görmüşler. Eşek pencereden içeri baktığında içeride, masanın üzerinde harika yemekler olan ve ganimetlerini paylaşan bir grup hırsız görmüş. Dört arkadaşın karnı çok açmış, hırsızları kaçırmak için bir plan yapmışlar.
//                
//                Eşek pencerenin önüne geçmiş, köpek eşeğin sırtına tırmanmış, kedi köpeğin omuzlarına çıkmış, horoz da kedinin başına konmuş. Eşek "Üç!" dediği anda hepsi birden bağarmaya başlamış. Eşek anırmış, köpek havlamış, kedi miyavlamış ve horoz ötmüş. Pencereden giren bu devasa, garip gölgeli ve korkunç sesli "canavarı" gören hırsızlar korkudan çığlık atarak ormana kaçmışlar. Dört arkadaş kulübeye girip güzelce karınlarını doyurmuşlar ve o kadar rahat etmişler ki, Bremen'e gitmekten vazgeçip ömürlerinin sonuna kadar o kulübede mutluça, dostça yaşamışlar.
//                """,
//                    "imageURL": "bremen_bg",
//                    "ageCategory": "5-6 Yas",
//                    "themeCategory": "Arkadaslik"
//                ]
//            ),
//            Story(
//                id: "8", dictionary: [
//                    "time": "4 dk",
//                    "title": "Parmak Çocuk",
//                    "description": """
//                Eskiden, odunculuk yaparak geçinen fakir ama iyi kalpli bir aile yaşarmış. Çocukları olmadığı için çok üzülürlermiş. Bir gün "Keşke bir çocuğumuz olsa, boyu bir parmak kadar bile olsa onu çok severdik," demişler. Gerçekten de bir süre sonra sadece başparmak büyüklüğünde, akıllı ve sevimli bir oğulları olmuş. Adını Parmak Çocuk koymuşlar.
//                
//                Boyu çok küçük olsa da, Parmak Çocuk kardeşlerinden ve köydeki diğer çocuklardan çok daha zeki ve cesurmuş. Bir gün ormanda ailesiyle odun toplarken yoğun bir sise yakalanmışlar ve yollarını kaybetmişler. Gece olduğunda uzakta devasa bir şatonun ışığını görmüşler ve sığınmak için oraya gitmişler. Ancak burası kötü kalpli ve çok açgözlü bir devin şatosuymuş!
//                
//                Dev onları uyurken yakalayıp hapse atmış. Herkes korkudan ağlarken, minik Parmak Çocuk parmaklıkların arasından kolayca dışarı süzülmüş. Dev uyurken onun cebindeki devasa anahtarı tüm gücüyle iterek yere düşürmüş ve zindanın kapısını açmış.
//                
//                Ailesi dışarı çıkarken, Parmak Çocuk devin yatağının başucunda duran, yedi fersahlık sihirli çizmeleri de fark etmiş. Ufak tefek boyuna rağmen bu çizmelerin içine girmiş ve çizmeler anında onun minik ayaklarına göre küçülmüş! Sihirli çizmeler sayesinde ailesini bir adımda ormanın sonuna, evlerine ulaştırmış. Devin şatosundan aldıkları altınlarla da bir daha hiç fakirlik çekmeden, mutlu mesut yaşamışlar.
//                """,
//                    "imageURL": "tom_thumb_bg",
//                    "ageCategory": "5-6 Yas",
//                    "themeCategory": "Macera"
//                ]
//            ),
//            Story(
//                id: "9", dictionary: [
//                    "time": "5 dk",
//                    "title": "Külkedisi",
//                    "description": """
//                Bir zamanlar, babasını kaybettikten sonra kötü kalpli üvey annesi ve iki şımarık üvey kız kardeşiyle yaşamak zorunda kalan çok güzel bir genç kız varmış. Onu bütün gün evde çalıştırır, en pis işleri yaptırırlarmış. Üstü başı hep kül içinde olduğu için ona Külkedisi derlermiş. Külkedisi ne kadar yorulursa yorulsun her zaman nazik ve güler yüzlüymüş.
//                
//                Bir gün saraydan bir haber gelmiş. Ülkenin prensi evleneceği kızı seçmek için büyük bir balo düzenliyormuş ve ülkedeki tüm genç kızlar davetliymiş. Üvey kız kardeşleri en güzel elbiselerini giyip baloya gitmişler ama Külkedisi'ni evde, şöminenin başında bırakmışlar. Külkedisi çaresizce ağlarken birden bir ışık parlamış ve İyilik Perisi ortaya çıkmış.
//                
//                Peri, sihirli değneğiyle bir balkabağını harika bir faytona, fareleri bembeyaz atlara dönüştürmüş. Sonra değneğini Külkedisi'ne dokundurmuş ve onun yırtık elbiseleri, parıl parıl parlayan mavi bir balo elbisesine dönüşmüş. Ayaklarında ise camdan, zarif pabuçlar varmış. Peri ona "Unutma," demiş, "Gece yarısı saat on iki olduğunda büyü bozulacak, o zamana kadar saraydan ayrılmalısın."
//                
//                Külkedisi baloya girdiğinde güzelliğiyle herkesi büyülemiş. Prens tüm gece sadece onunla dans etmiş. Ancak saat kulesi gece yarısını vurmaya başladığında, Külkedisi perinin sözünü hatırlayıp hızla merdivenlerden aşağı koşmuş. Koşarken cam ayakkabılarından birini merdivende düşürmüş. Prens ertesi gün tüm ülkeyi dolaşarak bu cam ayakkabının sahibini aramış. Ayakkabı ne üvey kız kardeşlere ne de başkasına uymuş. Sadece Külkedisi'nin narin ayağına tam oturmuş. Prens ve Külkedisi evlenip sarayda sonsuza dek mutlu yaşamışlar.
//                """,
//                    "imageURL": "cinderella_bg",
//                    "ageCategory": "3-4 Yas",
//                    "themeCategory": "Uyku"
//                ]
//            ),
//            Story(
//                id: "10", dictionary: [
//                    "time": "2 dk",
//                    "title": "Gökyüzündeki Aydede",
//                    "description": """
//                Güneş yavaş yavaş dağların arkasında kaybolduğunda, gökyüzü önce turuncuya, sonra pembeye ve en sonunda da koyu bir laciverte bürünür. İşte tam o anda, puf puf bulutların arasından tonton yüzlü, gümüş sakallı Aydede bize gülümseyerek uyanır.
//                
//                Aydede'nin görevi çok önemlidir. Dünyadaki tüm çocuklar yatağına yattığında, onlara karanlıktan korkmasınlar diye gökyüzünden tatlı, gümüş rengi bir ışık yollar. Yıldızlar da ona eşlik eder; minik minik göz kırparak Aydede'nin masalına katılırlar.
//                
//                Rüzgar hafifçe ağaçların yapraklarını sallar ve "Hışşş, hışşş" diyerek doğanın ninnisini fısıldar. Kuşlar yuvalarında uykuya dalar, çiçekler taç yapraklarını kapatıp sabah güneşini beklemeye başlar. Aydede pencereden odana doğru bakar, "İyi uykular küçüğüm, en güzel rüyalar senin olsun," der. Sen gözlerini kapatıp uykuya daldığında, Aydede sabaha kadar senin başında sevgiyle nöbet tutar. İyi geceler, tatlı rüyalar...
//                """,
//                    "imageURL": "moon_grandpa_bg",
//                    "ageCategory": "0-2 Yas",
//                    "themeCategory": "Uyku"
//                ]
//            )
        ]
        
        for story in storiesToUpload {
            db.collection("stories").addDocument(data: [
                "title": story.title,
                "description": story.description,
                "time": story.time,
                "imageURL": story.imageURL,
                "ageCategory": story.ageCategory,
                "themeCategory": story.themeCategory
            ]) { error in
                if let error = error {
                    print("Hata oluştu: \(error)")
                } else {
                    print("\(story.title) başarıyla Firebase'e eklendi!")
                }
            }
        }
    }
}
