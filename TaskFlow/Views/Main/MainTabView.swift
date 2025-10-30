import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var settingsViewModel = SettingsViewModel()
    
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Ana Sayfa", systemImage: "house.fill")
                }
            
            TaskListView()
                .tabItem {
                    Label("Görevler", systemImage: "list.bullet")
                }
            
            SettingsView()
                .environmentObject(settingsViewModel)
                .tabItem {
                    Label("Ayarlar", systemImage: "gearshape.fill")
                }
        }
        .preferredColorScheme(settingsViewModel.colorScheme)
    }
}

#Preview {
    MainTabView()
        .environmentObject(AuthViewModel())
}


