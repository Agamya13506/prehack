# Comic Design Reference

Comic style UI design guidelines and code examples.

## Design Principles

### Core Design Rules

| Property | Value | Description |
|----------|-------|-------------|
| Border Width | `2.0` (standard), `1.5` (list) | Comic style border |
| Border Radius | `12` (large), `8` (small) | Rounded corners |
| Elevation | `0` | Always no shadow |
| Spacing | Multiple of 8 | 8, 16, 24, 32... |

### Color Usage Rules

| Usage | Theme Color |
|-------|------------|
| Primary | `colorScheme.primary` |
| Secondary | `colorScheme.secondary` |
| Card/Container | `colorScheme.surface` |
| Border | `colorScheme.outline` |
| Text/Icon | `colorScheme.onSurface` |

### Typography Rules

| Usage | Text Style |
|-------|------------|
| Body | `textTheme.bodyLarge` |
| Title | `textTheme.titleMedium` |
| Button | `textTheme.labelLarge` |

---

## Theme Guidelines

### Mandatory Rules

```dart
// ❌ NEVER DO THIS
Text('Login')                              // Hardcoded text
color: Colors.blue                         // Hardcoded color
fontSize: 16                               // Hardcoded size
border: Border.all()                       // Border not allowed (use outline)
elevation: 4                               // Must be 0
ElevatedButton(
  child: Text('Click', style: TextStyle(...))  // Inline style overrides theme
)

// ✅ ALWAYS DO THIS
Text(T.login)                              // i18n translation
color: Theme.of(context).colorScheme.primary   // Theme color
style: Theme.of(context).textTheme.bodyLarge   // Theme text style
elevation: 0                               // Flat design
ElevatedButton(child: Text(T.click))       // Theme handles styling
```

---

## ComicButton System

Unified reusable button component library.

### Core Design Principles

- **Border**: outline color, 2.0px thickness
- **Elevation**: Always 0 (flat design)
- **Corners**: borderRadius 12 (normal) or fully rounded (full/pill)
- **Colors**: theme-based (surface, primary, secondary)

### Design Options

| Option | Values | Usage |
|--------|--------|-------|
| ComicButtonRounded | `full`, `normal` | Button shape |
| ComicButtonPadding | `large`, `medium`, `small` | Button padding |
| ComicButtonTextSize | `large`, `medium`, `small` | Text size |

### Quick Reference

| Button Style | rounded | padding | textSize |
|-------------|---------|---------|----------|
| Large CTA | `full` | `large` | `large` |
| Standard | `normal` | `medium` | `medium` |
| Compact | `normal` | `small` | `small` |

---

## ComicTextFormField

Reusable text input component with Comic design language.

### Design Principles

- **Border**: outline color, 1.0px thickness
- **Elevation**: Always 0
- **Corners**: borderRadius 12
- **Colors**: surface background, outline border, primary on focus

### Border States

| State | Color | Thickness |
|-------|-------|-----------|
| Enabled | outline | 1.0px |
| Focused | primary | 1.0px |
| Error | error | 1.0px |
| Disabled | outline 50% | 1.0px |

---

## Comic AppBar

App bar and header sections with Comic design.

### Design Specs

| Property | Value |
|----------|-------|
| Height | 56px |
| Border | Bottom only |
| Border thickness | 2.0px |
| Border color | `colorScheme.outline` |
| Title style | `titleLarge` |
| Elevation | 0 |

---

## Comic SnackBar

Notification message system following Comic design principles.

### Design Specs

| Property | Value |
|----------|-------|
| Border thickness | 2.0px |
| Border Radius | 12px |
| Elevation | 0 |
| Action | Floating |
| Margin | 16px all |
| Padding | horizontal 16px, vertical 12px |

### Available Functions

```dart
// Success
showComicSuccessSnackBar(context, T.profileUpdateSuccess);

// Error
showComicErrorSnackBar(context, T.nicknameRequired);

// Info
showComicInfoSnackBar(context, T.pleaseWait);

// Warning
showComicWarningSnackBar(context, T.pleaseCheckInput);
```
