# 📱 Özellik Detayları

## Görev Durum Akışı
```
Planlandı → Yapılacak → Çalışmada → Kontrol → Tamamlandı
   🔵         🟠          🟣         🟡         🟢
```

## Rol Bazlı Erişim

| Özellik | Admin | Kullanıcı |
|---------|-------|-----------|
| Görev Oluşturma | ✅ | ❌ |
| Görev Görüntüleme | Tümü | Atananlar |
| Görev Düzenleme | ✅ | ✅ |
| Görev Silme | ✅ | ❌ |
| Durum Değiştirme | ✅ | ✅ |
| PDF Oluşturma | ✅ | ✅ |
| Kullanıcı Atama | ✅ | ❌ |

## Ana Ekran Özellikleri

**İstatistik Kartları:**
- 📊 Toplam Görev Sayısı
- ✅ Tamamlanan Görevler
- 🔄 Devam Eden Görevler
- ⚠️ SLA Uyarı Sayısı

**Hızlı İşlemler:**
- 📄 Raporlarım (tüm kullanıcılar)
- ⚠️ SLA Uyarıları (tüm kullanıcılar)
- ➕ Yeni Görev Oluştur (sadece admin)
