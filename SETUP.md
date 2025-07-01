# Quick Setup Guide - NewsFlow

Get your news app running with images in 5 minutes! 🚀

## Quick Start (No API Keys Required)

The app will work without API keys, but you'll see limited content. For the best experience with rich images, follow the steps below.

## Step 1: Get Your First API Key (Recommended)

### NewsAPI.org - Best for Images ⭐⭐⭐⭐⭐
1. Go to [newsapi.org/register](https://newsapi.org/register)
2. Sign up with your email
3. Copy your API key (it looks like: `abc123def456ghi789`)
4. Open `lib/services/news_service.dart`
5. Replace `YOUR_NEWS_API_KEY` with your actual key

```dart
static const String _newsApiKey = 'abc123def456ghi789'; // Your actual key here
```

## Step 2: Run the App

```bash
flutter pub get
flutter run
```

That's it! You should now see news articles with images. 🎉

## Want More Content? Get Additional API Keys

### GNews API (100 requests/day)
1. Visit [gnews.io/register](https://gnews.io/register)
2. Get your API key
3. Replace `YOUR_GNEWS_API_KEY` in the service file

### Bing News API (1,000 requests/month)
1. Go to [Azure Portal](https://portal.azure.com/)
2. Create a free account
3. Create "Bing Search v7" resource
4. Get your subscription key
5. Replace `YOUR_BING_API_KEY` in the service file

## Troubleshooting

### No Images Showing?
- Check if your API key is correctly set
- Verify you haven't exceeded the daily limit
- Check your internet connection
- Look at the debug console for error messages

### API Key Not Working?
- Make sure you copied the entire key
- Check if the API service is working
- Verify your account is activated

### Still No Content?
The app will show a loading indicator if no APIs are configured. Add at least one API key to see content.

## API Limits (Free Tiers)

| API | Requests/Day | Best For |
|-----|-------------|----------|
| NewsAPI | 500 | Images, Tech News |
| GNews | 100 | General News |
| Bing | 1,000/month | Rich Images |
| MediaStack | 500/month | Global Coverage |
| NewsData | 200 | Smart Extraction |

## Need Help?

- Check the main [README.md](README.md) for detailed documentation
- Open an issue on GitHub if you encounter problems
- The app is designed to work with any combination of APIs

---

**Pro Tip**: Start with NewsAPI.org - it has the best image support and highest free tier limit! 📰✨ 