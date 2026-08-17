# 🏙️ NagarDrishti (नगरदृष्टी / नगरदृष्टि)
### *Vikasit Nagpur Civic AI & SLA Governance Platform*

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.12+-0175C2?logo=dart)](https://dart.dev)
[![AI Engine](https://img.shields.io/badge/AI-Google%20Gemini%20Vision-8E75B2?logo=google)](https://ai.google.dev)
[![Backend](https://img.shields.io/badge/Backend-Firebase%20Firestore-FFCA28?logo=firebase)](https://firebase.google.com)
[![GIS Maps](https://img.shields.io/badge/Maps-OpenStreetMap-7EBC6F?logo=openstreetmap)](https://www.openstreetmap.org)
[![Weather API](https://img.shields.io/badge/Weather-Open--Meteo-38BDF8)](https://open-meteo.com)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

---

## 📌 Executive Overview

**NagarDrishti** is a state-of-the-art, AI-powered smart city civic issue reporting, duplicate clustering, and SLA governance platform built for **Nagpur Municipal Corporation (NMC)**. 

The application empowers citizens to report civic infrastructural defects (potholes, sewer overflows, streetlight failures, garbage accumulation) using **Google Gemini Vision AI** for automated classification, **Geolocator** for real-time GPS tracking, and **Open-Meteo REST API** for live hyper-local weather intelligence.

For municipal department officers and field repair contractors, NagarDrishti introduces **Before vs. After AI Proof-of-Fix Auditing**, **Automated SLA Routing**, and **Financial Expenditure Transparency**.

---

## 🌟 Key Features & Capabilities

### 1. 📸 Gemini Vision AI Auto-Classification
- **Instant Photo Scanning**: Captures camera/gallery photos and sends them to Google Gemini 1.5 Flash Vision AI.
- **Smart Category & Severity Extraction**: Automatically detects defect category (Roads, Waterlogging, Electrical, Sanitation), severity rating (`Low`, `Medium`, `High`, `Critical`), and confidence score (e.g. 96%).
- **Automated Department Routing**: Auto-routes complaints to corresponding NMC departments with pre-configured SLA countdown targets.

### 2. 🤖 Proof-of-Fix Before/After AI Audit
- **Visual Repair Validation**: When field contractors complete a repair, they upload a proof-of-work photo.
- **Gemini AI Visual Comparison**: Gemini Vision compares the **BEFORE** (problem) and **AFTER** (repaired) images to compute a **Fix Quality Score** (e.g. *95% Verified Fix*) and generate a summary statement before marking the ticket `Resolved`.

### 3. 🚨 Emergency SOS Mode (4-Hour SLA Escalation)
- **High-Hazard Fast Track**: Dedicated **🚨 SOS Critical Hazard Switch** in the reporting screen for immediate public risks (fallen live wires, open manholes on main roads).
- **Fast-Track Dispatch**: Applies a **4-hour SLA emergency target** and triggers priority FCM push notifications to emergency response squads.

### 4. 📍 Real-Time Live GPS & OpenStreetMap GIS Visualization
- **Live User Location Marker**: Displays a pulsing blue dot at the user's real GPS position.
- **Auto Reverse-Geocoding**: Dynamically looks up exact street names and assigns the corresponding NMC Ward (e.g. *Chhatrapati Square, Ward 4 - Dhantoli*).
- **Heatmaps & Cluster Markers**: Interactive OpenStreetMap engine (`flutter_map`) displaying complaint hotspots, red alerts, active works, and resolved tickets.

### 5. 🌤️ Real-Time Weather Intelligence (Zero API Key)
- **Open-Meteo REST API Integration**: Queries `api.open-meteo.com` in real-time without requiring any private/paid API key.
- **Predictive Rain Alerts**: Displays live temperature, relative humidity (%), and rainfall accumulation (mm) on the dashboard, auto-escalating waterlogging SLA timers when heavy rain is forecast.

### 6. 🎙️ Voice-to-Text Reporting & Multilingual Localization
- **Speech-to-Text Input**: Citizens can dictate complaint details using hands-free voice notes.
- **Dynamic Multilingual Support**: Instant dynamic UI language switching across **English**, **Marathi (मराठी)**, and **Hindi (हिंदी)** via `AppLanguageNotifier`.

### 7. 📐 50-Meter Haversine Spatial Duplicate Clustering
- **Duplicate Prevention Engine**: Checks new reports against existing database entries within a 50-meter radius.
- **Red Alert Clustering**: Merges duplicate reports into a master ticket; if duplicate report count reaches 10+, the issue is automatically upgraded to **RED ALERT** status.

### 8. 🏆 Civic Karma & Gamification Leaderboard
- **Reputation System**: Citizens earn **+50 Karma Points** for verified reports, accepted fixes, and community upvotes.
- **Citizen Rankings & Badges**: Gamified leaderboard encouraging active community civic participation.

### 9. 📊 Municipal Officer Desk & Financial Analytics
- **Department Portal**: Official dashboard for NMC officers to manage ticket queues, assign field workers, and update work order statuses.
- **Financial Transparency**: Tracks estimated repair budget allocation (₹ Lakhs), ward SLA compliance rates (94.2%), and active field squad counts.

---

## 🏗️ Tech Stack Architecture

| Layer | Technology / Package | Purpose |
| :--- | :--- | :--- |
| **Framework** | Flutter 3.x (Dart ^3.12) | Cross-platform Mobile & Web codebase |
| **State Management** | `flutter_riverpod: ^2.5.1` | Reactive state management & provider dependency injection |
| **Navigation & Routing** | `go_router: ^14.2.0` | Declarative URL-based application routing |
| **AI Processing** | `google_generative_ai: ^0.4.0` | Google Gemini 1.5 Flash Vision AI model integration |
| **Backend & Auth** | `cloud_firestore: ^5.2.1`, `firebase_auth: ^5.1.4` | Live NoSQL database, anonymous & email auth |
| **Storage & Messaging** | `firebase_storage: ^12.1.3`, `firebase_messaging: ^15.0.4` | Media cloud storage & FCM push notification alerts |
| **Maps & GIS** | `flutter_map: ^7.0.2`, `latlong2: ^0.9.1` | OpenStreetMap engine with CartoDB Voyager tiles |
| **GPS & Geocoding** | `geolocator: ^12.0.0`, `geocoding: ^3.0.0` | Hardware GPS location & reverse geocoding placemarks |
| **Live Weather** | Open-Meteo REST API (`api.open-meteo.com`) | Free, open-source real-time weather forecasts (No API key) |
| **Speech Recognition** | `speech_to_text: ^7.3.0` | Voice-to-text audio dictation |
| **UI & Typography** | `google_fonts: ^6.2.1`, `intl: ^0.19.0` | Modern typography & date/currency formatting |

---

## 📂 Project Directory Structure

```
nagardrishti/
├── android/                   # Native Android application configuration
├── ios/                       # Native iOS application configuration
├── lib/
│   ├── firebase_options.dart  # Firebase project credentials & configuration
│   ├── main.dart              # Application entry point & ProviderScope setup
│   └── src/
│       ├── core/
│       │   ├── constants/     # App colors (AppColors), NMC wards, department SLA maps
│       │   ├── router/        # GoRouter definition (login, shell, details, admin)
│       │   ├── theme/         # Sleek Nagpur Dark Slate Material 3 Theme
│       │   └── utils/         # Multilingual provider (AppLanguage), seed data
│       └── features/
│           ├── active_work/   # Ongoing municipal infrastructure works tracker
│           ├── admin/         # NMC Department Officer portal & budget analytics
│           ├── auth/          # Authentication controllers & user models (AppUser)
│           ├── departments/   # NMC Department routing models (Roads, Water, Waste)
│           ├── home/          # Main Citizen Dashboard & Live Open-Meteo Weather banner
│           ├── issues/        # Issue model, duplicate detection, Gemini verification
│           ├── leaderboard/   # Civic Karma leaderboard & citizen rankings
│           ├── map/           # Real-world OpenStreetMap GIS view & live GPS marker
│           ├── notifications/ # FCM push notification service & alert dispatch
│           ├── profile/       # User profile, statistics, and settings
│           ├── public_feed/   # Community feed with upvotes & status filters
│           ├── report/        # Gemini AI camera photo scanner, location & SOS switch
│           ├── shell/         # Navigation shell with bottom navbar & language picker
│           └── weather/       # Open-Meteo weather repository & cache models
├── pubspec.yaml               # Flutter package dependencies & assets manifest
└── README.md                  # Project documentation
```

---

## 🚀 Getting Started & Setup Guide

### Prerequisites
1. **Flutter SDK**: Version `^3.12.2` or higher ([Install Flutter](https://docs.flutter.dev/get-started/install)).
2. **Dart SDK**: Included with Flutter.
3. **Android Studio** / **VS Code** with Flutter and Dart extensions.

### Installation Steps

1. **Clone the Repository**
   ```bash
   git clone https://github.com/your-username/nagardrishti.git
   cd nagardrishti
   ```

2. **Install Dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Configuration**
   - Ensure Firebase project options are correctly configured in `lib/firebase_options.dart`.
   - If running locally without live Firebase credentials, the app automatically runs in **Mock Fallback Mode** with seeded demo data.

4. **Run Code Analysis**
   ```bash
   flutter analyze
   ```

5. **Launch the Application**
   ```bash
   flutter run
   ```

---

## ⚡ API Integrations & Hardware Services

### 1. Google Gemini 1.5 Flash Vision API
- **Endpoint**: `google_generative_ai` SDK
- **Usage**:
  - Image Classification: Analyzes issue photos to output Category, Severity, and Confidence score.
  - Fix Quality Audit: Compares Before and After photos to output a Fix Quality Percentage (0–100%) and summary.

### 2. Open-Meteo Weather REST API
- **Endpoint**: `https://api.open-meteo.com/v1/forecast`
- **Parameters**: `latitude`, `longitude`, `current=temperature_2m,relative_humidity_2m,rain,weather_code`
- **Key Feature**: Completely free, public, non-commercial API requiring **zero secret API key**.

### 3. Device Location & Geocoding
- **Hardware GPS**: Requests high-accuracy coordinates via `Geolocator`.
- **Placemark Lookup**: Reverse-geocodes latitude and longitude into street names via `geocoding`.

---

## 🧪 Verification & Testing

To run static lint analysis and unit tests:

```bash
# Run Flutter Linter Analysis
flutter analyze

# Run Flutter Unit & Widget Tests
flutter test
```

*Status*: **0 errors, 0 warnings (Clean Build)**

---

## 🤝 Contributing

Contributions are welcome! To contribute to NagarDrishti:
1. Fork the repository.
2. Create your feature branch (`git checkout -b feature/AmazingFeature`).
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`).
4. Push to the branch (`git push origin feature/AmazingFeature`).
5. Open a Pull Request.

---

## 📜 License

Distributed under the **MIT License**. See `LICENSE` for more information.

---

<p align="center">
  <b>NagarDrishti</b> — Built with ❤️ for Nagpur Smart City Governance
</p>

