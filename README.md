# 🇪🇬 Nile Explorer

**Nile Explorer** is a modern Flutter application designed to help users discover and explore Egypt's most fascinating destinations. The app provides an immersive travel experience with personalized features such as favorites, ratings, weather updates, and dynamic recommendations.

Built using **Flutter**, **Firebase**, and **MVVM Architecture**, Nile Explorer focuses on performance, scalability, and a seamless user experience.

---

## ✨ Features

### 🔐 Authentication

* Email & Password Sign In
* User Registration
* Google Sign-In
* Logout
* Password Reset
* Email Verification
* Guest Mode Support

---

### 🗺️ Explore Egypt

Discover famous landmarks and hidden gems across Egypt.

Features include:

* Browse destinations by governorate
* Explore different categories
* View detailed information about each place
* Hidden Gems section
* Rich descriptions and image galleries

---

### 🏠 Dynamic Home Screen

Personalized sections powered by real-time data:

* ⭐ Top Rated Places
* 🔥 Trending Now
* 👁️ Most Viewed Places

---

### ❤️ Favorites System

Save your favorite destinations and access them anytime.

Features:

* Add to Favorites
* Remove from Favorites
* Dedicated Favorites Screen
* User-specific synchronization using Firestore

---

### ⭐ Rating System

Interactive rating experience with real-time updates.

Features:

* One rating per user per place
* Update existing ratings
* Automatic average rating calculation
* Automatic rating count updates
* Firestore Transactions for consistency

---

### 👁️ Views & Trending System

Improve recommendations through user activity.

Features:

* Increment views when opening place details
* Automatic Trending Score calculation
* Trending recommendations based on engagement

---

### 🌦️ Weather Integration

Stay informed before visiting destinations.

Displays:

* Current Weather Conditions
* Temperature
* Humidity
* Wind Speed

---

### 🌍 Localization

Multi-language support for a wider audience.

Supported Languages:

* English
* Arabic

Powered by:

* Easy Localization

---

## 🏗️ Architecture

The application follows **MVVM (Model–View–ViewModel)** architecture.

Project Structure:

```text
lib/
├── core/
├── data/
│   ├── datasources/
│   │   ├── local/
│   │   └── remote/
│   ├── models/
│   └── repositories/
├── viewmodels/
├── views/
└── app.dart
```

### Architecture Layers

#### Models

Represent application entities and Firestore models.

#### Data Sources

Handle data retrieval from:

* Firestore
* Local JSON assets

#### Repositories

Act as the single source of truth between ViewModels and Data Sources.

#### ViewModels (BLoC/Cubit)

Manage application state and business logic.

#### Views

Contain UI screens and widgets.

---

## 🛠️ Tech Stack

### Framework

* Flutter
* Dart

### Backend

* Firebase Authentication
* Cloud Firestore

### State Management

* flutter_bloc

### Localization

* easy_localization

### Design

* Material 3

---

## ⚡ Performance Considerations

Nile Explorer was designed with performance in mind:

* Lazy screen initialization
* IndexedStack navigation preservation
* Optimized Bloc rebuilds
* Firestore transaction support
* Local fallback for offline scenarios
* Reduced unnecessary Firestore reads

---

## 🚀 Getting Started

### Prerequisites

* Flutter SDK
* Firebase Project
* Android Studio or VS Code

### Installation

Clone the repository:

```bash
git clone https://github.com/your-username/nile-explorer.git
```

Navigate to the project:

```bash
cd nile-explorer
```

Install dependencies:

```bash
flutter pub get
```

Configure Firebase:

* Add `google-services.json` to:

```text
android/app/
```

Run the application:

```bash
flutter run
```

---

## 🔥 Firebase Collections Structure

```text
places/
favorites/
ratings/
users/{userId}/ratings/
```

---

## 📌 Future Enhancements

Potential improvements:

* Route Navigation to destinations
* AI-based Recommendations
* Offline Favorites Cache
* Push Notifications
* Travel Itinerary Planner
* Nearby Places Discovery
* Trip History

---

## 👨‍💻 Developed By

**Anas**

Flutter Developer passionate about building scalable and user-friendly mobile applications.

---

## 📄 License

This project is intended for educational and portfolio purposes.
