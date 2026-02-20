# Flutter Layout Reference

Flutter layout and scroll screen configuration guidelines.

## Layout Selection Guide

| Screen Type | Recommended Layout | Reason |
|------------|-------------------|--------|
| AppBar + scroll content | `CustomScrollView + Sliver` | Advanced UX |
| Fixed header + list | `CustomScrollView + Sliver` | Composable |
| Login/Input form | `ListView` | Easy keyboard handling |
| Simple scroll | `SingleChildScrollView` | Simple implementation |
| Fixed layout | `Column/Row` | No scroll needed |

---

## CustomScrollView with Slivers

### When to Use

- AppBar/tabs/fixed header + scroll content
- Fixed header + list + sections
- Advanced UX like pinned/floating/stretch
- Large screen standard layouts

### Basic Structure

```dart
CustomScrollView(
  slivers: [
    SliverAppBar(pinned: true, title: Text(T.title)),
    SliverList(
      delegate: SliverChildBuilderDelegate(
        (_, i) => ItemWidget(i),
        childCount: 100,
      ),
    ),
  ],
)
```

### SliverAppBar Options

| Property | Description | Use Case |
|----------|-------------|----------|
| `pinned: true` | AppBar stays visible | Always visible AppBar |
| `floating: true` | Shows when scrolling up | Quick access needed |
| `snap: true` | Snap effect with floating | Smooth UX |
| `stretch: true` | Pull to expand AppBar | Refresh effect |
| `expandedHeight` | Height when expanded | Image background AppBar |

---

## ListView for Forms

### When to Use

- Screens requiring keyboard input
- Login, signup, input forms
- Content that may overflow screen

### Basic Structure

```dart
ListView(
  padding: const EdgeInsets.all(16),
  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
  children: [
    ComicTextFormField(
      controller: _emailController,
      labelText: T.email,
    ),
    const SizedBox(height: 16),
    ComicTextFormField(
      controller: _passwordController,
      labelText: T.password,
      obscureText: true,
    ),
    const SizedBox(height: 24),
    ComicPrimaryButton(
      onPressed: _submit,
      child: Text(T.login),
    ),
  ],
)
```

### ListView.builder vs ListView

| Method | When to Use |
|--------|-------------|
| `ListView(children: [...])` | Few items (under 10) |
| `ListView.builder()` | Many or dynamic items |
| `ListView.separated()` | When separator is needed |

---

## Common Layout Patterns

### Pattern 1: AppBar + Scroll List

```dart
Scaffold(
  body: CustomScrollView(
    slivers: [
      SliverAppBar(
        pinned: true,
        title: Text(T.title),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 2, color: scheme.outline),
        ),
      ),
      SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => ListItem(items[index]),
          childCount: items.length,
        ),
      ),
    ],
  ),
)
```

### Pattern 2: Tabs + Scroll Content

```dart
DefaultTabController(
  length: 3,
  child: Scaffold(
    body: NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) => [
        SliverAppBar(
          pinned: true,
          title: Text(T.title),
          bottom: const TabBar(tabs: [Tab(text: 'Tab 1'), ...]),
        ),
      ],
      body: TabBarView(children: [TabContent1(), TabContent2(), TabContent3()]),
    ),
  ),
)
```

---

## CarouselView

### Mandatory Guidance

> **Important**: When implementing carousel (slider) UI in Flutter, **must use `CarouselView`**.
> Use Flutter's built-in widget, not external packages.

### Material Design 3 Carousel Layout Types

| Layout | Description |
|--------|-------------|
| **Multi-browse** | Shows large/medium/small items at once |
| **Uncontained** | Items scroll to container edges |
| **Hero** | One large item and small items |
| **Full-screen** | Single item fills entire screen |

### Implementation Steps

#### Step 1: Create CarouselController

```dart
final controller = CarouselController(initialItem: 0);
```

#### Step 2: Pass Controller to CarouselView

```dart
CarouselView(
  controller: controller,
  // ...
)
```

#### Step 3: Add children and itemExtent

```dart
CarouselView(
  controller: controller,
  itemExtent: 200.0,
  children: items,
)
```

### CarouselView.weighted (Dynamic Size)

Use `flexWeights` to dynamically adjust item size ratios:

```dart
CarouselView.weighted(
  flexWeights: const <int>[3, 2, 1],  // Center → edge order
  consumeMaxWeight: false,
  children: items,
)
```

---

## Quick Reference

| Situation | Use Widget |
|-----------|------------|
| AppBar + scroll | `CustomScrollView + SliverAppBar + SliverList` |
| Input form | `ListView + keyboardDismissBehavior` |
| Tabs + scroll | `NestedScrollView + TabBarView` |
| Grid layout | `SliverGrid` or `GridView.builder` |
| Convert widget to Sliver | `SliverToBoxAdapter` |
| Fixed header | `SliverPersistentHeader` |
| Carousel/slider | `CarouselView` or `CarouselView.weighted` |
