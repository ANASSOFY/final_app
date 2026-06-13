You are a senior Flutter architect.

I have a production-ready Flutter application called "Nile Explorer".

Your task is to improve and extend the application WITHOUT breaking existing functionality.

Rules:
- Preserve all current features.
- Follow MVVM architecture strictly.
- Do not modify existing business logic unless necessary.
- Maintain compatibility with Firebase Authentication and Cloud Firestore.
- Avoid introducing performance regressions.
- Keep the UI responsive and consistent with Material 3 design.

Current features:

• Firebase Authentication
    - Email/Password
    - Google Sign-In
    - Logout
    - Password Reset
    - Email Verification

• Firestore Integration
    - Places Collection
    - Favorites Collection
    - Ratings Collection
    - User Ratings Subcollections

• Places System
    - Explore Egyptian destinations
    - Place Details
    - Governorate categorization
    - Hidden Gems

• Dynamic Home Screen
    - Top Rated
    - Trending Now
    - Most Viewed

• Favorites System
    - Add Favorite
    - Remove Favorite
    - Favorites Page
    - Per-user synchronization

• Rating System
    - One rating per user per place
    - Update existing ratings
    - Automatic average rating calculation
    - Rating count updates

• Views System
    - Increment views on opening details
    - Trending score calculation

• Weather Integration
    - Current weather
    - Temperature
    - Humidity
    - Wind Speed

• Localization
    - Arabic
    - English

• State Management
    - flutter_bloc

• Architecture
    - MVVM

Requirements:
- Use clean code principles.
- Keep repositories isolated.
- Avoid duplicate Firestore reads.
- Use transactions where needed.
- Optimize rebuilds.
- Preserve existing navigation behavior.
- Document any modifications clearly.
