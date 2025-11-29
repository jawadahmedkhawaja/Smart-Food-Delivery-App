# Contributing to Smart Food Delivery App

Thank you for your interest in contributing to SFDA! This document provides guidelines for contributing to the project.

## 🎯 Ways to Contribute

1. **Report bugs** - Found a bug? Open an issue!
2. **Suggest features** - Have an idea? We'd love to hear it!
3. **Submit pull requests** - Code improvements, bug fixes, new features
4. **Improve documentation** - Fix typos, add examples, clarify instructions
5. **Write tests** - Help us improve code coverage

## 🚀 Getting Started

1. **Fork the repository** to your GitHub account
2. **Clone your fork** locally:
   ```bash
   git clone https://github.com/your-username/sfda_mark_1.git
   ```
3. **Create a branch** for your changes:
   ```bash
   git checkout -b feature/your-feature-name
   ```

## 📝 Code Style Guidelines

### Dart/Flutter Code
- Follow the [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- Use `flutter format .` before committing
- Add comments for complex logic
- Use meaningful variable and function names

### Example:
```dart
// Good ✅
Future<void> fetchUserOrders() async {
  final orders = await FirebaseFirestore.instance
      .collection('orders')
      .where('userId', isEqualTo: currentUserId)
      .get();
}

// Bad ❌
Future<void> get() async {
  var x = await FirebaseFirestore.instance.collection('orders').get();
}
```

## 🔍 Testing

Before submitting a PR:
1. Test your changes on both Android and iOS (if possible)
2. Ensure the app builds without errors:
   ```bash
   flutter build apk --release
   ```
3. Check for linting errors:
   ```bash
   flutter analyze
   ```

## 📤 Submitting Changes

1. **Commit your changes**:
   ```bash
   git add .
   git commit -m "feat: Add feature description"
   ```

2. **Use conventional commit messages**:
   - `feat:` - New feature
   - `fix:` - Bug fix
   - `docs:` - Documentation changes
   - `style:` - Code style changes (formatting)
   - `refactor:` - Code refactoring
   - `test:` - Adding tests
   - `chore:` - Maintenance tasks

3. **Push to your fork**:
   ```bash
   git push origin feature/your-feature-name
   ```

4. **Open a Pull Request** on GitHub with:
   - Clear title and description
   - Screenshots (if UI changes)
   - Reference to related issues

## 🐛 Reporting Bugs

When reporting bugs, please include:
- **Description** - What happened?
- **Steps to reproduce** - How can we recreate it?
- **Expected behavior** - What should have happened?
- **Screenshots** - If applicable
- **Environment** - OS, Flutter version, device

## 💡 Suggesting Features

Feature suggestions should include:
- **Problem description** - What problem does this solve?
- **Proposed solution** - How would it work?
- **Alternatives considered** - Other approaches you thought about
- **Mockups/wireframes** - Visual representation (if applicable)

## 📋 Pull Request Checklist

Before submitting a PR, ensure:
- [ ] Code follows Dart style guidelines
- [ ] App builds successfully
- [ ] No linting errors (`flutter analyze`)
- [ ] Tested on Android (and iOS if possible)
- [ ] Commit messages follow conventional format
- [ ] Documentation updated (if needed)
- [ ] Screenshots added (for UI changes)

## 🤝 Code of Conduct

- Be respectful and inclusive
- Welcome newcomers and help them learn
- Focus on constructive feedback
- Respect differing viewpoints

## 📞 Questions?

If you have questions about contributing, feel free to:
- Open an issue with the `question` label
- Contact the maintainer via email

---

Thank you for contributing to SFDA! 🎉
