import Foundation
import SwiftUI
import Combine

@MainActor
class SettingsViewModel: ObservableObject {
    @Published var colorScheme: ColorScheme?
    @Published var syncOnlyOnWiFi: Bool = false
    @Published var notificationSLA: Bool = true
    @Published var notificationAssignment: Bool = true
    @Published var notificationChecklist: Bool = false
    
    private let syncOnlyOnWiFiKey = "sync_only_wifi"
    private let notificationSLAKey = "notification_sla"
    private let notificationAssignmentKey = "notification_assignment"
    private let notificationChecklistKey = "notification_checklist"
    
    init() {
        loadPreferences()
    }
    
    func loadPreferences() {
        loadThemePreference()
        loadSyncPreference()
        loadNotificationPreferences()
    }
    
    private func loadThemePreference() {
        if let savedTheme = UserDefaults.standard.string(forKey: Constants.themeKey) {
            switch savedTheme {
            case "light":
                colorScheme = .light
            case "dark":
                colorScheme = .dark
            default:
                colorScheme = nil
            }
        }
    }
    
    private func loadSyncPreference() {
        syncOnlyOnWiFi = UserDefaults.standard.bool(forKey: syncOnlyOnWiFiKey)
    }
    
    private func loadNotificationPreferences() {
        notificationSLA = UserDefaults.standard.object(forKey: notificationSLAKey) as? Bool ?? true
        notificationAssignment = UserDefaults.standard.object(forKey: notificationAssignmentKey) as? Bool ?? true
        notificationChecklist = UserDefaults.standard.object(forKey: notificationChecklistKey) as? Bool ?? false
    }
    
    func saveThemePreference(_ scheme: ColorScheme?) {
        if let scheme = scheme {
            let themeString = scheme == .light ? "light" : "dark"
            UserDefaults.standard.set(themeString, forKey: Constants.themeKey)
        } else {
            UserDefaults.standard.removeObject(forKey: Constants.themeKey)
        }
        colorScheme = scheme
    }
    
    func saveSyncPreference(_ wifiOnly: Bool) {
        UserDefaults.standard.set(wifiOnly, forKey: syncOnlyOnWiFiKey)
        syncOnlyOnWiFi = wifiOnly
    }
    
    func saveNotificationPreferences() {
        UserDefaults.standard.set(notificationSLA, forKey: notificationSLAKey)
        UserDefaults.standard.set(notificationAssignment, forKey: notificationAssignmentKey)
        UserDefaults.standard.set(notificationChecklist, forKey: notificationChecklistKey)
    }
    
    func performManualSync() async -> Bool {
        try? await _Concurrency.Task.sleep(nanoseconds: 1_000_000_000) // Simülasyon
        return true
    }
    
    func exportData() -> String {
        let exportData: [String: Any] = [
            "version": "1.0.0",
            "exportDate": ISO8601DateFormatter().string(from: Date()),
            "settings": [
                "theme": colorScheme == .light ? "light" : (colorScheme == .dark ? "dark" : "system"),
                "syncOnlyOnWiFi": syncOnlyOnWiFi,
                "notifications": [
                    "sla": notificationSLA,
                    "assignment": notificationAssignment,
                    "checklist": notificationChecklist
                ]
            ]
        ]
        
        if let jsonData = try? JSONSerialization.data(withJSONObject: exportData, options: .prettyPrinted),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            return jsonString
        }
        
        return "{}"
    }
}


