# TaskFlow - Modern Görev Yönetim Sistemi

> **MultiAcademy Modern iOS Programming Course** - Eğitimi Bitirme Projesi.


## 📖 Proje Hakkında

TaskFlow, kurumsal ortamlar için tasarlanmış, modern ve kullanıcı dostu bir görev yönetim uygulamasıdır. Firebase backend altyapısı ile gerçek zamanlı veri senkronizasyonu, SLA (Service Level Agreement) takibi ve PDF raporlama özellikleri sunar.

Bu proje, iOS geliştirme bootcamp programının bitirme ödevi olarak geliştirilmiştir ve modern iOS geliştirme pratiklerini, MVVM mimari desenini ve Firebase entegrasyonunu kapsamlı şekilde uygular.

## ✨ Özellikler

### 🔐 Kimlik Doğrulama & Yetkilendirme
- Firebase Authentication ile güvenli giriş/kayıt
- Email/Password tabanlı kullanıcı yönetimi
- Rol bazlı yetkilendirme (Admin/Kullanıcı)
- Uygulama içi rol değiştirme (test amaçlı)

### 📋 Görev Yönetimi
- **CRUD Operasyonları**: Görev oluşturma, okuma, güncelleme, silme
- **Durum Akış Yönetimi**: Planlandı → Yapılacak → Çalışmada → Kontrol → Tamamlandı
- **Görev Atama**: Kullanıcılara görev atama sistemi
- **Filtreleme**: Durum bazlı görev filtreleme
- **Gerçek Zamanlı Güncellemeler**: Firestore real-time listeners

### ⏰ SLA (Service Level Agreement) Yönetimi
- **Otomatik SLA Takibi**: Görev süre aşımı kontrolü
- **Görsel Uyarı Sistemi**: Renk kodlu durum göstergeleri
  - 🟢 Güvenli (24+ saat)
  - 🟡 Uyarı (24-6 saat)
  - 🟠 Kritik (6 saat altı)
  - 🔴 Gecikmiş
- **SLA Dashboard**: Yaklaşan son tarihli görevler için özel ekran

### 📊 Raporlama
- **PDF Rapor Oluşturma**: PDFKit ile native PDF üretimi
- **Rapor Arşivi**: Oluşturulan raporların saklanması
- **PDF Önizleme**: Uygulama içi PDF görüntüleyici
- **Paylaşım**: iOS Share Sheet entegrasyonu

### 🎨 Kullanıcı Arayüzü
- **Modern SwiftUI**: Tamamen SwiftUI ile geliştirilmiş
- **Tema Yönetimi**: Açık/Koyu/Sistem modu desteği
- **Responsive Design**: Tüm iOS cihazlarla uyumlu
- **Animasyonlar**: Smooth transitions ve animations

### ⚙️ Ayarlar & Kişiselleştirme
- **Offline Senkronizasyon**: WiFi-only veri senkronizasyonu
- **Bildirim Tercihleri**: SLA, atama ve checklist bildirimleri
- **Veri Export**: JSON formatında ayar dışa aktarımı
- **Manuel Senkronizasyon**: İsteğe bağlı veri yenileme

## 🚧 Bilinen Sınırlamalar

- PDF storage UserDefaults ile sınırlı (küçük dosyalar)
- Offline mode kısmi destek (sadece cache)
- Push notifications henüz implement edilmedi
- Çoklu dil desteği yok (sadece Türkçe)


## Dökümanlar

- [Mimari](Documents/Mimari.md)
- [Teknolojiler](Documents/Teknolojiler.md)
- [Özellikler](Documents/Özellikler.md)
- [Test Senaryoları](Documents/Test.md)
- [Öğrenme Çıktıları](Documents/Öğrenme.md)
