# Flutter Provider State Management Reference

Provider package state management guidelines.

## Overview

Provider is the most widely used state management solution in Flutter. Based on InheritedWidget, it makes sharing and managing state easy.

### Mandatory Rules

| Rule | Description |
|------|-------------|
| Use Selector | Use Selector instead of Consumer |
| read() location | Use only in event handlers |
| watch() restriction | Do NOT use outside build method |

---

## Core Concepts

### ChangeNotifier

Class that notifies subscribers of state changes.

```dart
class AppState extends ChangeNotifier {
  int _counter = 0;

  int get counter => _counter;

  void incrementCounter() {
    _counter++;
    notifyListeners();
  }
}
```

### ChangeNotifierProvider

Provides ChangeNotifier to widget tree and manages resources automatically.

```dart
ChangeNotifierProvider(
  create: (context) => AppState(),
  child: const MyApp(),
)
```

---

## State Access Methods

### context.read<T>()

Use when **only reading** state. Does not subscribe, so no rebuild occurs.

```dart
// Access state in event handler (no rebuild needed)
ElevatedButton(
  onPressed: () {
    context.read<AppState>().incrementCounter();
  },
  child: Text(T.increase),
)
```

### context.watch<T>() - Restrictions

Must only be used in build method. **Do NOT use in event handlers**.

```dart
// ❌ NEVER DO THIS
onPressed: () {
  context.watch<AppState>().incrementCounter();  // Error!
}

// ✅ Only in build method (prefer Selector)
@override
Widget build(BuildContext context) {
  final state = context.watch<AppState>();
  return Text('${state.counter}');
}
```

---

## Selector Widget

### Concept

`Selector` subscribes to only specific parts of state to **prevent unnecessary rebuilds**.

**Mandatory Rule**: Use `Selector` wherever possible.

### Basic Format

```dart
Selector<ModelClass, DataType>(
  selector: (context, model) => model.value,
  builder: (context, value, child) => Text('$value'),
)
```

| Parameter | Description |
|-----------|-------------|
| `selector` | Returns specific value to subscribe to |
| `builder` | Builds widget using selected value |
| `child` | Non-rebuilding child widget (optimization) |

### Usage Example

```dart
class CounterWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Selector<AppState, int>(
      selector: (_, state) => state.counter,
      builder: (context, count, child) => Column(
        children: [
          Text('Counter: $count'),
          child!,
        ],
      ),
      child: ElevatedButton(
        onPressed: () {
          context.read<AppState>().incrementCounter();
        },
        child: Text(T.increase),
      ),
    );
  }
}
```

### Selector Functions

Selector can return computed/transformed/composed results:

```dart
// String composition
Selector<UserState, String>(
  selector: (_, state) => '${state.firstName} ${state.lastName}',
  builder: (_, fullName, __) => Text(fullName),
)

// Collection filtering/counting
Selector<TodoState, int>(
  selector: (_, state) => state.items.where((e) => e.done).length,
  builder: (_, doneCount, __) => Text('Done: $doneCount'),
)
```

### Selecting Multiple Values

Use Records to bundle multiple values:

```dart
Selector<AppState, (int, String)>(
  selector: (_, state) => (state.counter, state.name),
  builder: (context, data, child) {
    final (count, name) = data;
    return Text('$name: $count');
  },
)
```

---

## Selector vs Consumer

```dart
// ❌ NOT RECOMMENDED: Subscribes to entire state
Consumer<AppState>(
  builder: (context, state, child) => Text('${state.counter}'),
)

// ✅ RECOMMENDED: Subscribes only to needed value
Selector<AppState, int>(
  selector: (_, state) => state.counter,
  builder: (context, count, child) => Text('$count'),
)
```

---

## Best Practices

### 1. Prefer Selector

```dart
// ✅ Recommended
Selector<AppState, int>(
  selector: (_, state) => state.counter,
  builder: (context, count, child) => Text('$count'),
)
```

### 2. Use read() in Event Handlers

```dart
// ✅ Recommended
onPressed: () {
  context.read<AppState>().incrementCounter();
}
```

### 3. Use child Parameter

Pass non-rebuilding child widgets through `child` parameter.

```dart
Selector<AppState, int>(
  selector: (_, state) => state.counter,
  builder: (context, count, child) => Column(
    children: [
      Text('$count'),
      child!,
    ],
  ),
  child: const ExpensiveWidget(),
)
```

### 4. Single Responsibility

```dart
// ❌ NOT RECOMMENDED: One class with all state
class AppState extends ChangeNotifier {
  User? user;
  List<Post> posts;
  ThemeMode theme;
  // ... too many responsibilities
}

// ✅ RECOMMENDED: Separate by responsibility
class UserState extends ChangeNotifier {}
class PostState extends ChangeNotifier {}
class ThemeState extends ChangeNotifier {}
```

---

## Quick Reference

| Situation | Method |
|-----------|---------|
| Display state in UI | Use `Selector<T, V>` |
| Change state on button click | Use `context.read<T>()` |
| Subscribe to multiple values | Use `Selector<T, (V1, V2)>` |
| Optimize expensive widgets | Use `child` parameter |
