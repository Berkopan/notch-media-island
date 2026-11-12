# Notch Media Island — Kurulum

Kod yazmanız gerekmiyor. macOS 14 Sonoma veya daha yenisi gerekiyor.

## Hazır uygulama varsa: en kolay yol

1. Reponun **Releases** bölümüne girin. Henüz sürüm yoksa aşağıdaki kaynak koddan kurulum yolunu kullanın.
2. Apple menüsü → **Bu Mac Hakkında** bölümünde Apple M-serisi çip görünüyorsa `arm64`, Intel işlemci görünüyorsa `x86_64` ZIP dosyasını indirin.
3. ZIP’i açın. **Notch Media Island.app** dosyasını **Uygulamalar** klasörüne sürükleyin ve açın.
4. Mouse’u çentiğe getirin. Dock’ta simge görünmemesi normaldir.

Hazır uygulama için Xcode gerekmez. Mevcut paketler notarize edilmemiştir; aşağıdaki güvenlik açıklamasını okuyun.

## Clone veya kaynak ZIP’inden kurulum

1. **Code → Download ZIP** ile indirin ve ZIP’i açın. Clone’ladıysanız mevcut proje klasörünü açın.
2. **Start.command** dosyasına çift tıklayın. Terminal penceresi açılır, adımlar burada görünür; komut yazmanıza gerek yok.
3. Apple’ın ücretsiz Command Line Tools araçları eksikse `y` yazıp Enter’a basarak Apple kurulum penceresini açabilirsiniz. Kurulumu tamamlayın, sonra **Start.command** dosyasını yeniden açın. Apple araçlarının kurulumu internet, boş disk alanı ve bazen yönetici parolası gerektirir.
4. İlk derlemeyi bekleyin. Uygulama kullanıcı klasörünüzdeki **Applications** klasörüne kurulup açılır. Hazır mesajından sonra Enter ile Terminal penceresini kapatabilirsiniz.

Sonraki açılışlarda Finder → **Git → Ana Klasör → Applications → Notch Media Island.app** yolunu kullanın. Bu, genel Uygulamalar klasöründen ayrı, size ait klasördür. Uygulamanın kendisini kurmak için yönetici parolası gerekmez. Her açılışta Start.command çalıştırmayın.

## Kullanım

- Çentiğin üzerine gelin: panel açılır. Uzaklaşın: kısa gecikmeyle kapanır.
- Şarkı başlatın: macOS’a bildirilmiş medya bilgileri görünür.
- Çubuğu sürükleyerek ileri/geri sarın.
- Sağ üstteki dalga simgesinden adayı gizleyebilir, bağlantıyı yenileyebilir veya **Çıkış** yapabilirsiniz.
- Otomatik başlangıç eklenmez.

## macOS güvenlik mesajları

İndirilen uygulama veya Start.command için “geliştirici doğrulanamadı” uyarısı çıkabilir. Mevcut paketler Developer ID ile imzalanmış ve Apple tarafından notarize edilmiş değildir. Kaynağı doğruladıktan sonra açmaya karar verirseniz [Apple’ın resmî yönergelerini](https://support.apple.com/en-us/102445) izleyin: açmayı denedikten sonra **Sistem Ayarları → Gizlilik ve Güvenlik → Yine de Aç** seçeneği ilgili öğe için görünebilir. Kurumsal Mac’lerde kısıtlanabilir. Kötü amaçlı yazılım uyarısını aşmaya çalışmayın.

Betikler Gatekeeper’ı kapatmaz, karantina işaretlerini silmez veya güvenlik ayarlarını değiştirmez.

## Sorun giderme

| Durum | Çözüm |
| --- | --- |
| Start.command metin olarak açılıyor | Sağ tık → Birlikte Aç → Terminal. |
| Çalıştırma izni yok | Terminal’e `bash ` yazın (sonunda boşluk), Start.command dosyasını pencereye sürükleyin, Enter’a basın. |
| Apple araçları eksik | Apple kurulumunu tamamen bitirip Start.command dosyasını yeniden açın. |
| Xcode ilk kurulum/lisans hatası | Xcode’u açıp Apple’ın ilk kurulum adımlarını tamamlayın. |
| “Önce uygulamadan çıkın” | Dalga simgesi → Çıkış, sonra yeniden kurulum. |
| Parça görünmüyor | Önce macOS’un Şu An Çalınan bölümünde bilgi olup olmadığını kontrol edin. Her kaynak bilgi sağlamaz. |
| Bağlantı kesildi | Dalga simgesi → Medya bağlantısını yenile. |
| macOS güncellemesinden sonra bozuldu | Private API değişmiş olabilir; macOS sürümünüzle birlikte Issue açın. |

## Güncelleme ve kaldırma

Yeni kodu indirin/çekin, uygulamadan çıkın ve **Start.command** dosyasını açın. Mevcut kurulum güncellenir. Kaldırmak için uygulamadan çıkıp kurulu **Notch Media Island.app** dosyasını Çöp’e taşıyın. Proje klasörünü ayrıca silebilirsiniz. Müzik dosyalarınıza dokunulmaz.
