# Quick Start Guide

This guide will help you get the Smart Food Delivery App up and running quickly.

## ⚡ Quick Installation (5 minutes)

### 1. Prerequisites Check
```bash
# Check Flutter installation
flutter --version

# Should show Flutter 3.9.2 or higher
```

### 2. Clone & Install
```bash
git clone https://github.com/yourusername/sfda_mark_1.git
cd sfda_mark_1
flutter pub get
```

### 3. Firebase Setup (Simplified)

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click **"Add project"** or use existing project
3. Enable these services:
   - ✅ Authentication (Email/Password)
   - ✅ Firestore Database
   - ✅ Storage

4. Download `google-services.json`:
   - Click on Android icon
   - Register app with package name: `com.example.sfda_mark_1`
   - Download the JSON file
   - Place it in `android/app/`

### 4. Run the App
```bash
# Connect your Android device or start emulator
flutter run
```

That's it! 🎉

## 🎮 Testing the App

### Default Test Accounts

For testing, create accounts with these roles:

| Role | Test Email | Password |
|------|-----------|----------|
| Customer | customer@test.com | Test123! |
| Restaurant | restaurant@test.com | Test123! |
| Delivery | delivery@test.com | Test123! |
| Admin | admin@test.com | Test123! |

**Note**: You need to manually set roles in Firestore after signup:
1. Sign up with the email
2. Go to Firestore Console
3. Find the user in `users` collection
4. Set the `role` field

### Quick Test Flow

1. **Customer Flow**:
   - Sign up as customer
   - Verify email
   - Browse restaurants
   - Add items to cart
   - Place order

2. **Restaurant Flow**:
   - Sign up as restaurant
   - Complete restaurant details form
   - Add menu items
   - Accept incoming orders

3. **Delivery Flow**:
   - Sign up as delivery personnel
   - View available deliveries
   - Accept delivery
   - Navigate to customer

## 🐛 Common Issues

### Issue: "google-services.json not found"
**Solution**: Make sure you downloaded the file from Firebase and placed it in `android/app/`

### Issue: "Execution failed for task ':app:processDebugGoogleServices'"
**Solution**: Your `google-services.json` package name must match `com.example.sfda_mark_1`

### Issue: "Maps not showing"
**Solution**: Add your Google Maps API key in `android/app/src/main/AndroidManifest.xml`

### Issue: "Email verification not sending"
**Solution**: 
1. Check Firebase Console → Authentication → Templates
2. Make sure email verification is enabled
3. Check spam folder

## 📱 Building Release APK

```bash
# Clean previous builds
flutter clean

# Build release APK
flutter build apk --release

# APK location
# build/app/outputs/flutter-apk/app-release.apk
```

## 🔧 Development Tips

### Hot Reload
Press `r` in terminal while app is running to hot reload changes.

### Check for Errors
```bash
flutter analyze
```

### Format Code
```bash
flutter format .
```

### Check Dependencies
```bash
flutter pub outdated
```

## 📚 Next Steps

- Read the full [README.md](README.md)
- Check out [CONTRIBUTING.md](CONTRIBUTING.md) to contribute
- Add screenshots to `screenshots/` folder
- Customize the app for your needs

## 💬 Need Help?

- Open an issue on GitHub
- Check existing issues for solutions
- Read Flutter documentation: [flutter.dev](https://flutter.dev)

---

Happy coding! 🚀
