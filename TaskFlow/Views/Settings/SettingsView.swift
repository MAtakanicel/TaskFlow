import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    @State private var showSignOutAlert = false
    @State private var showSyncSuccess = false
    @State private var isSyncing = false
    @State private var showExportSheet = false
    @State private var exportedData = ""
    
    var body: some View {
        NavigationStack {
            Form {

                Section{
                    if let user = authViewModel.currentUser {
                        HStack {
                            Image(systemName: "person.circle.fill")
                                .font(.title)
                                .foregroundStyle(.blue)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(user.displayName)
                                    .font(.headline)
                                Text(user.email)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(.vertical, 4)
                        
                        HStack {
                            Text("Rol")
                                .foregroundStyle(.secondary)
                            
                            Spacer()
                            
                            Picker("Rol", selection: Binding(
                                get: { user.role },
                                set: { newRole in
                                    _Concurrency.Task {
                                        await authViewModel.updateUserRole(newRole)
                                    }
                                }
                            )) {
                                Text("Kullanıcı").tag(UserRole.user)
                                Text("Yönetici").tag(UserRole.admin)
                            }
                            .pickerStyle(.segmented)
                            .frame(width: 200)
                        }
                    }
                } footer: {
                    Text("Test için rolünüzü değiştirebilirsiniz")
                        .font(.caption)
                }
                

                Section("Tema: Açık / Koyu / Sistem") {
                    Picker("Görünüm", selection: $settingsViewModel.colorScheme) {
                        Text("Sistem").tag(nil as ColorScheme?)
                        Text("Açık").tag(ColorScheme.light as ColorScheme?)
                        Text("Koyu").tag(ColorScheme.dark as ColorScheme?)
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: settingsViewModel.colorScheme) { _, newValue in
                        settingsViewModel.saveThemePreference(newValue)
                    }
                }
                

                Section {
                    Toggle(isOn: $settingsViewModel.syncOnlyOnWiFi) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Yalnızca Wi-Fi'da")
                                .font(.body)
                            Text("Verileri sadece Wi-Fi bağlantısında senkronize et")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .onChange(of: settingsViewModel.syncOnlyOnWiFi) { _, newValue in
                        settingsViewModel.saveSyncPreference(newValue)
                    }
                } header: {
                    Text("Offline Senkron")
                }
                

                Section("Manuel Senkronla") {
                    Button {
                        performManualSync()
                    } label: {
                        HStack {
                            Image(systemName: "arrow.clockwise")
                            Text("Şimdi Senkronize Et")
                            Spacer()
                            if isSyncing {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                            }
                        }
                    }
                    .disabled(isSyncing)
                }
                
                Section {
                    Toggle(isOn: $settingsViewModel.notificationSLA) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("SLA Uyarıları")
                                .font(.body)
                            Text("Görev süre aşımı yaklaştığında bildirim")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .onChange(of: settingsViewModel.notificationSLA) { _, _ in
                        settingsViewModel.saveNotificationPreferences()
                    }
                    
                    Toggle(isOn: $settingsViewModel.notificationAssignment) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Atama Bildirimleri")
                                .font(.body)
                            Text("Yeni görev atandığında bildirim")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .onChange(of: settingsViewModel.notificationAssignment) { _, _ in
                        settingsViewModel.saveNotificationPreferences()
                    }
                    
                    Toggle(isOn: $settingsViewModel.notificationChecklist) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Checklist Hatırlatıcıları")
                                .font(.body)
                            Text("Checklist güncellemeleri için bildirim")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .onChange(of: settingsViewModel.notificationChecklist) { _, _ in
                        settingsViewModel.saveNotificationPreferences()
                    }
                } header: {
                    Text("Bildirimler: SLA + Atama + Checklist")
                }
                
                Section {
                    Button {
                        exportedData = settingsViewModel.exportData()
                        showExportSheet = true
                    } label: {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                            Text("Veri Değişikliğini Aktar (JSON)")
                        }
                    }
                } header: {
                    Text("Veri Değişikliğini Aktarma (JSON)")
                } footer: {
                    Text("Ayarlarınızı JSON formatında dışa aktarın")
                        .font(.caption)
                }
                

                Section("Uygulama") {
                    LabeledContent("Versiyon") {
                        Text("1.0.0")
                            .foregroundStyle(.secondary)
                    }
                    
                    LabeledContent("Yapı") {
                        Text("1")
                            .foregroundStyle(.secondary)
                    }
                }
                
                Section {
                    Button(role: .destructive) {
                        showSignOutAlert = true
                    } label: {
                        HStack {
                            Spacer()
                            Label("Çıkış Yap", systemImage: "rectangle.portrait.and.arrow.right")
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("Ayarlar")
            .alert("Çıkış Yap", isPresented: $showSignOutAlert) {
                Button("İptal", role: .cancel) { }
                Button("Çıkış Yap", role: .destructive) {
                    authViewModel.signOut()
                }
            } message: {
                Text("Çıkış yapmak istediğinizden emin misiniz?")
            }
            .alert("Senkronizasyon Tamamlandı", isPresented: $showSyncSuccess) {
                Button("Tamam", role: .cancel) { }
            } message: {
                Text("Verileriniz başarıyla senkronize edildi.")
            }
            .sheet(isPresented: $showExportSheet) {
                NavigationStack {
                    ScrollView {
                        Text(exportedData)
                            .font(.system(.caption, design: .monospaced))
                            .padding()
                    }
                    .navigationTitle("Dışa Aktarılan Veri")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Kapat") {
                                showExportSheet = false
                            }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            ShareLink(item: exportedData) {
                                Label("Paylaş", systemImage: "square.and.arrow.up")
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func performManualSync() {
        isSyncing = true
        _Concurrency.Task {
            let success = await settingsViewModel.performManualSync()
            isSyncing = false
            if success {
                showSyncSuccess = true
            }
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(AuthViewModel())
        .environmentObject(SettingsViewModel())
}


