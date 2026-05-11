# 🚀 VZHA TrackIt — Multi-Tenant Finance Platform

VZHA TrackIt is an enterprise-grade, multi-tenant financial management platform built with Flutter and Supabase. It features a robust offline-first architecture, a dynamic low-code module builder, and cross-platform support for Mobile and Web.

![App Logo](App_log.png)

## ✨ Key Features

### 🏢 Multi-Tenancy & Isolation
- **Workspaces**: Create separate workspaces for your Individual finances, Family accounts, or Business entities.
- **Role-Based Access**: Secure data isolation using Supabase Row-Level Security (RLS).
- **Tenant Management**: Easily switch between tenants without re-logging.

### 🛠️ Low-Code Custom Module Builder
- **Dynamic UI**: Build custom data entry forms (Inventory, Projects, Asset tracking) directly from the app.
- **JSON-Driven Engine**: Modules are defined via JSON schemas and rendered dynamically.
- **Data Persistence**: Custom module records are stored in a flexible schema-less format.

### 📶 Offline-First Experience
- **Isar Integration**: Local high-performance NoSQL database (Isar) for offline data access on Mobile and Desktop.
- **Smart Sync**: Automatically caches data from Supabase and allows seamless interaction even without internet connectivity.
- **Web Support**: On Web, the app falls back to direct Supabase interaction to ensure maximum stability (due to current Isar 3.x web limitations).

### 📊 Advanced Reporting
- **PDF Ledger**: Generate professional monthly financial statements.
- **CSV Export**: Export transaction data for further analysis in Excel or Google Sheets.
- **Interactive Charts**: Visualize income vs. expenses with interactive graphs.

### 🔒 Enterprise Security
- **Biometric Lock**: Secure your data with Fingerprint or FaceID (via `local_auth`).
- **Supabase Auth**: Industry-standard JWT-based authentication.
- **Workspace Privacy**: Cross-tenant data isolation enforced at the database level.

### 🎨 Personalization
- **Dynamic Themes**: Dark/Light mode and custom primary color selection.
- **Typography**: Support for various Google Fonts (Inter, Roboto, Outfit, etc.).
- **Multi-Currency**: Global support with selectable base currencies (USD, EUR, INR, GBP, etc.).

---

## 🛠️ Technology Stack

- **Frontend**: Flutter (3.2x+)
- **State Management**: Riverpod (Functional & Class-based Providers)
- **Backend**: Supabase (PostgreSQL, Auth, Storage, Edge Functions)
- **Local DB**: Isar (Cross-platform NoSQL)
- **Navigation**: GoRouter (Declarative Routing)
- **Styling**: Material 3 with Dynamic Theme Support

---

## 🚀 Getting Started

### 1. Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install)
- [Supabase Project](https://supabase.com)

### 2. Installation
```bash
# Clone the repository
git clone https://github.com/Veera1011/SCH-Bookchain.git

# Navigate to project
cd vzha_trackit

# Install dependencies
flutter pub get

# Generate Isar Schema (Requires build_runner)
flutter pub run build_runner build --delete-conflicting-outputs
```

### 3. Run the App
```bash
# Run on Chrome
flutter run -d chrome

# Run on Android
flutter run -d android
```

---

## 📦 Deployment & CI/CD
The project includes a **GitHub Actions** workflow (`flutter_build.yml`) that automatically generates:
- Release APKs and AABs for Android.
- Web deployment bundles.
- Automatic builds on every push to the `main` branch.

---

## 📝 License
Copyright © 2024 VZHA TrackIt. All rights reserved.
