# GoRouter Reference

Flutter navigation guidelines using GoRouter routing package.

## Overview

GoRouter is a declarative routing package for Flutter that can also be used on the web.

### Basic Setup

```dart
final GlobalKey<NavigatorState> globalNavigatorKey = GlobalKey();
BuildContext get globalContext => globalNavigatorKey.currentContext!;

final router = GoRouter(
  navigatorKey: globalNavigatorKey,
  redirect: (context, state) {
    if (state.fullPath == EntryScreen.routeName) {
      return null;
    }
    if (FirebaseAuth.instance.currentUser == null) {
      return EntryScreen.routeName;
    }
    return null;
  },
  routes: [
    GoRoute(
      path: HomeScreen.routeName,
      name: HomeScreen.routeName,
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: EntryScreen.routeName,
      name: EntryScreen.routeName,
      pageBuilder: (context, state) => NoTransitionPage<void>(
        key: state.pageKey,
        child: const EntryScreen(),
      ),
    ),
  ],
);
```

---

## Parameter Passing

Three ways to pass parameters with GoRouter.

### 1. Path Parameters

URL named parameters.

**Route Definition:**

```dart
GoRoute(
  path: '/sample/:id1/:id2',
  name: 'sample',
  builder: (context, state) => SampleWidget(
    id1: state.pathParameters['id1'],
    id2: state.pathParameters['id2'],
  ),
)
```

**Navigation:**

```dart
context.goNamed(
  'sample',
  pathParameters: {'id1': 'param1', 'id2': 'param2'},
);
```

### 2. Query Parameters

URL query strings. **Strings only**.

**Route Definition:**

```dart
GoRoute(
  name: 'sample',
  path: '/sample',
  builder: (context, state) => SampleWidget(
    id1: state.uri.queryParameters['id1'],
    id2: state.uri.queryParameters['id2'],
  ),
)
```

### 3. Extra (Object Passing)

Pass objects directly. **Not reflected in web URL**.

**Route Definition:**

```dart
GoRoute(
  path: '/family',
  builder: (context, state) => FamilyScreen(
    family: state.extra! as Family,
  ),
)
```

### Parameter Comparison

| Method | Type | Web URL Reflected | Use Case |
|--------|------|------------------|-----------|
| `pathParameters` | String only | Yes | IDs, slugs |
| `queryParameters` | String only | Yes | Filters, search |
| `extra` | Any Object | No | Complex objects |

---

## Navigation Methods

### context.go()

Replaces current stack (like web location change).

```dart
context.go('/home');
context.go('/profile/123');
```

### context.goNamed()

Navigate by name.

```dart
context.goNamed('profile', pathParameters: {'id': '123'});
```

### context.push()

Adds new page to stack (back navigation possible).

```dart
context.push('/detail/123');
context.pushNamed('detail', pathParameters: {'id': '123'});
```

### context.pop()

Returns to previous page.

```dart
context.pop();
Navigator.of(context).pop(resultValue);
```

### Receiving Values

```dart
final result = await context.push<String>('/select-item');
if (result != null) {
  // Handle result
}
context.pop('selected_value');
```

---

## Redirect and Guards

### Login-based Redirect

```dart
GoRouter(
  redirect: (context, state) {
    final isLoggedIn = FirebaseAuth.instance.currentUser != null;
    final isLoginRoute = state.matchedLocation == '/login';

    if (!isLoggedIn && !isLoginRoute) {
      return '/login';
    }

    if (isLoggedIn && isLoginRoute) {
      return '/home';
    }

    return null;
  },
)
```

### Specific Path Protection

```dart
GoRouter(
  redirect: (context, state) {
    final isLoggedIn = authState.isLoggedIn;
    final protectedPaths = ['/profile', '/settings', '/orders'];

    final isProtectedRoute = protectedPaths.any(
      (path) => state.matchedLocation.startsWith(path),
    );

    if (!isLoggedIn && isProtectedRoute) {
      return '/login?redirect=${state.matchedLocation}';
    }

    return null;
  },
)
```

---

## Screen Template

Basic structure for pages with GoRouter.

### Basic Structure

```dart
class NameScreen extends StatefulWidget {
  static const String routeName = '/Name';

  static Function(BuildContext ctx) push = (ctx) => ctx.push(routeName);
  static Function(BuildContext ctx) go = (ctx) => ctx.go(routeName);

  const NameScreen({super.key});

  @override
  State<NameScreen> createState() => _NameScreenState();
}

class _NameScreenState extends State<NameScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Name')),
      body: const Column(children: [Text("Name")]),
    );
  }
}
```

### Usage

```dart
NameScreen.push(context);  // Push (back navigation possible)
NameScreen.go(context);    // Go (stack replacement)
```

### With Dynamic Parameters

```dart
class ProfileScreen extends StatefulWidget {
  static const String routeName = '/Profile/:id';

  static void push(BuildContext ctx, String id) =>
      ctx.push(routeName.replaceFirst(':id', id));

  static void go(BuildContext ctx, String id) =>
      ctx.go(routeName.replaceFirst(':id', id));

  final String id;
  const ProfileScreen({super.key, required this.id});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}
```

---

## Quick Reference

| Action | Code |
|--------|------|
| Navigate (replace stack) | `context.go('/path')` |
| Navigate by name | `context.goNamed('name')` |
| Push (back possible) | `context.push('/path')` |
| Go back | `context.pop()` |
| Pop with value | `Navigator.of(context).pop(value)` |
| Path params | `pathParameters: {'id': '123'}` |
| Query params | `queryParameters: {'q': 'search'}` |
| Pass object | `extra: myObject` |
| Read params | `state.pathParameters['id']` |
| Read query | `state.uri.queryParameters['q']` |
