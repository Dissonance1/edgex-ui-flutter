# Honeycomb Edge

Honeycomb Edge is a powerful, Linux-native Flutter application designed for monitoring and managing **EdgeX Foundry V3** instances. It provides a sleek, modern interface for edge orchestration, data monitoring, and service configuration.

![Honeycomb Edge Logo](assets/images/logo.png)

## 🚀 Features

### 1. Metadata Management
Unified management for the core edge ecosystem:
- **Devices**: Register, edit, and monitor devices with flexible protocol support.
- **Device Profiles**: Upload and inspect YAML profiles; easily bridge device definitions.
- **Device Services**: View and manage registration for south-bound services.

### 2. Edge Processing & Application Services
- **Rules Engine**: Create eKuiper streams and defined rules (JSON) for real-time edge analytics.
- **Application Services**: Detailed inspection of app-functions-sdk-go services, including inspection of **Triggers**, **Pipeline Functions**, and **Application Settings**.

### 3. Support Services
- **Scheduler**: Full CRUD support for Intervals and Interval Actions.
- **Notification Center**: Manage V3 Subscriptions and monitor system notifications.

### 4. Data & Command
- **Event Monitor**: Real-time visualization of edge events and sensor readings.
- **Command Execution**: Send GET/PUT commands to devices directly from the UI.

## 🛠 Prerequisites

Before running Honeycomb Edge, ensure you have the following installed:

1.  **Flutter SDK**: [Follow Flutter installation guide](https://docs.flutter.dev/get-started/install/linux).
2.  **Linux Dev Tools**:
    ```bash
    sudo apt-get install clang cmake ninja-build pkg-config libgtk-3-dev
    ```
3.  **EdgeX Backend**: An EdgeX Foundry V3 instance must be accessible (locally or via network).

## 📥 Installation

1.  Clone the repository and navigate to the project directory:
    ```bash
    cd edgex_ui_flutter
    ```
2.  Fetch dependencies:
    ```bash
    flutter pub get
    ```

## 🏃 Running the Application

To run the app in debug mode on your Linux machine:
```bash
flutter run -d linux
```

## 📦 Building for Production

To create a release-ready Linux bundle:
```bash
flutter build linux
```
The executable will be located in `build/linux/x64/release/bundle/`.

## ⚙️ Configuration

The application currently targets `localhost` for EdgeX services. You can modify the base URLs in `lib/api/edgex_service.dart` to point to a remote EdgeX instance.

---
*Branded and Refined by Antigravity*
