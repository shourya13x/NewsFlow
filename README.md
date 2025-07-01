# NewsFlow 📰

<p align="center">
  <img src="screenshots/home.png" alt="Home" width="30%"/>
  <img src="screenshots/content.png" alt="Content" width="30%"/>
  <img src="screenshots/settings.png" alt="Settings" width="30%"/>
</p>

## Overview ✨

**NewsFlow** is a modern Flutter app that aggregates news from multiple APIs, providing real-time updates, category filtering, favorites, and a polished user experience with light/dark themes.

---

## Features 🚀

- 🔄 Real-time news fetching from multiple APIs
- 🗂️ Category filtering
- 🌙 Light & dark themes
- ⭐ Favorites management
- ⬇️ Pull-to-refresh
- 📱 Responsive UI for all devices

---

## APIs Used 🌐

- [NewsAPI.org](https://newsapi.org/)
- [GNews](https://gnews.io/)
- [Bing News](https://www.bing.com/news)
- [MediaStack](https://mediastack.com/)
- [NewsData.io](https://newsdata.io/)

---

## Technical Stack 🛠️

- **Flutter** (latest stable)
- **Provider** for state management
- **Dart** for business logic
- **REST API** integration
- **Material 3** design

---

## Project Structure 📁

```plaintext
lib/
  main.dart
  models/
  screens/
  services/
  widgets/
assets/
  fonts/
  images/
screenshots/
  home.png
  content.png
  settings.png
```

---

## Getting Started 🚦

1. **Clone the repo:**
   ```sh
   git clone https://github.com/shourya13x/NewsFlow.git
   cd NewsFlow
   ```
2. **Install dependencies:**
   ```sh
   flutter pub get
   ```
3. **Run the app:**
   ```sh
   flutter run
   ```

---

## Contributing 🤝

Contributions are welcome! Please open an issue or submit a pull request.

---

## Learn More

- [Flutter Documentation](https://docs.flutter.dev/)
- [State Management in Flutter](https://docs.flutter.dev/data-and-backend/state-mgmt/intro)

---

## Problems Faced & Solutions 🛠️

- 🔑 **API key limits:** Managed by rotating keys and fallback APIs.
- 🖼️ **Image consistency:** Handled missing/broken images gracefully.
- 🗂️ **Category mapping:** Unified categories across APIs.
- 🔄 **Cache-busting:** Ensured fresh data on pull-to-refresh.

---

**Made with ❤️ by Shourya** 