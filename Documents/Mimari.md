# 🏗️ Mimari

## MVVM (Model-View-ViewModel) Pattern

```
┌─────────────────────────────────────────────┐
│                   Views                     │
│  (SwiftUI Components - UI Only)             │
│  • LoginView, RegisterView                  │
│  • HomeView, TaskListView, TaskDetailView   │
│  • SettingsView, MyReportsView              │
└────────────────┬────────────────────────────┘
                 │ @Published Bindings
                 │ User Actions
┌────────────────▼────────────────────────────┐
│                ViewModels                   │
│  (Business Logic & State Management)        │
│  • AuthViewModel                            │
│  • TaskViewModel                            │
│  • SettingsViewModel                        │
│  • ReportsViewModel                         │
└────────────────┬────────────────────────────┘
                 │ Async Calls
                 │ Data Transformation
┌────────────────▼────────────────────────────┐
│                Services                     │
│  (Data Layer & External APIs)               │
│  • AuthService                              │
│  • FirebaseService                          │
│  • PDFService                               │
│  • ReportService                            │
└────────────────┬────────────────────────────┘
                 │
┌────────────────▼────────────────────────────┐
│                 Models                      │
│  (Data Structures)                          │
│  • Task, User, TaskReport                   │
│  • TaskStatus (Enum)                        │
│  • UserRole (Enum)                          │
└─────────────────────────────────────────────┘
```

## Proje Yapısı

```
TaskFlow/
├── App/
│   └── TaskFlowApp.swift                 # App entry point
│
├── Models/                                # Data models
│   ├── Task.swift                         # Task data structure
│   ├── User.swift                         # User data structure
│   ├── TaskReport.swift                   # Report data structure
│   └── TaskStatus.swift                   # Status enum
│
├── ViewModels/                            # Business logic
│   ├── AuthViewModel.swift                # Authentication logic
│   ├── TaskViewModel.swift                # Task management logic
│   ├── SettingsViewModel.swift            # Settings logic
│   └── ReportsViewModel.swift             # Reports logic
│
├── Views/                                 # User Interface
│   ├── Auth/
│   │   ├── LoginView.swift
│   │   └── RegisterView.swift
│   ├── Main/
│   │   ├── MainTabView.swift
│   │   └── HomeView.swift
│   ├── Tasks/
│   │   ├── TaskListView.swift
│   │   ├── TaskDetailView.swift
│   │   ├── CreateTaskView.swift
│   │   ├── MyReportsView.swift
│   │   ├── SLAWarningsView.swift
│   │   └── Components/
│   │       ├── TaskCardView.swift
│   │       ├── StatusBadgeView.swift
│   │       └── PDFKitView.swift
│   └── Settings/
│       └── SettingsView.swift
│
├── Services/                              # Data layer
│   ├── AuthService.swift                  # Firebase Auth wrapper
│   ├── FirebaseService.swift              # Firestore operations
│   ├── PDFService.swift                   # PDF generation
│   └── ReportService.swift                # Report management
│
└── Utilities/                             # Helpers
    ├── Constants.swift                    # App constants
    └── Extensions.swift                   # Swift extensions
```
