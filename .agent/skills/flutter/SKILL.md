---
name: flutter-skill
description: |
  Flutter development skill with UI/UX guidelines, state management, routing, and API integration. Use when developing Flutter apps, working with design, UI, UX, layouts, Provider, GoRouter, i18n, FCM, or Firebase Auth. (project)
---

# Flutter Skill

This skill provides **universal** guidelines for Flutter framework app development including UI/UX design, state management, networking, and API integration. It provides essential instructions that must be followed, not optional information.

## Table of Contents

- [Workflow](#workflow)
- [Core Principles](#core-principles)
- [Reference Documents](#reference-documents)

## Workflow

Follow this workflow based on developer requests:

1. **Design/UI/UX requests**: See [Comic Design](./comic-design.md)
   - Keywords: design, UI, UX, buttons, cards, layout, animation, Comic

2. **Layout requests**: See [Flutter Layout](./flutter-layout.md)
   - Keywords: layout, scroll, CustomScrollView, ListView, widget placement

3. **State management requests**: See [Provider](./provider.md)
   - Keywords: state management, Provider, Selector, ChangeNotifier

4. **Routing requests**: See [Go Route](./go_route.md)
   - Keywords: routing, navigation, GoRouter, page navigation

5. **Internationalization requests**: See [i18n](./i18n.md)
   - Keywords: i18n, translation, localization, arb

## Core Principles

### Mandatory Rules

```dart
// ❌ NEVER DO THIS
color: Colors.blue              // Hardcoded color
fontSize: 16                    // Hardcoded size
Text('Hello')                   // Hardcoded text
elevation: 4                    // Non-zero elevation

// ✅ ALWAYS DO THIS
color: Theme.of(context).colorScheme.primary  // Theme color
style: Theme.of(context).textTheme.bodyLarge  // Theme text style
Text(T.hello)                                  // i18n translation
elevation: 0                                   // Flat design
```

### Theme-based Styling

All colors, fonts, and styles must use `Theme.of(context)`:

| Usage | Usage Method |
|-------|-------------|
| Primary color | `Theme.of(context).colorScheme.primary` |
| Surface color | `Theme.of(context).colorScheme.surface` |
| Border color | `Theme.of(context).colorScheme.outline` |
| Body text | `Theme.of(context).textTheme.bodyLarge` |
| Title text | `Theme.of(context).textTheme.titleMedium` |

### Comic Design Summary

| Property | Value | Description |
|----------|-------|-------------|
| Border Width | `2.0` (standard), `1.0` (list) | Comic style border |
| Border Radius | `12` | Rounded corners |
| Elevation | `0` | No shadow |
| Spacing | Multiple of 8 | 8, 16, 24, 32... |

## Reference Documents

| Document | Content |
|----------|---------|
| [comic-design.md](./comic-design.md) | Comic UI design system, buttons, cards, forms, SnackBar |
| [flutter-layout.md](./flutter-layout.md) | Scroll screens, CustomScrollView, ListView patterns |
| [provider.md](./provider.md) | Provider state management, Selector, ChangeNotifier |
| [go_route.md](./go_route.md) | GoRouter routing, parameter passing, redirect |
| [i18n.md](./i18n.md) | Internationalization, ARB file management |

## Required pub.dev Packages

### file_cache_flutter

File cache library for Flutter applications with memory + file dual caching and TTL-based auto-expiration.

- **pub.dev**: [file_cache_flutter](https://pub.dev/packages/file_cache_flutter)

## Quick Reference

### Imports

```dart
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
```

### Animation (using flutter_animate)

```dart
Container()
  .animate()
  .fadeIn(duration: 300.ms)
  .slideX(begin: -0.2, end: 0)
```

### Icon Priority

When using Font Awesome Pro icons, priority: **Light > Regular > Solid**

```dart
FaIcon(FontAwesomeIcons.lightCamera)  // Light first
```
