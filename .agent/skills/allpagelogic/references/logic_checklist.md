# Webpage Logic Robustness Checklist

Use this checklist during every `allpagelogic` audit to ensure 100% coverage of common failure points.

## 🔐 Auth & Authorization
- [ ] **Auth Guard**: Does the page correctly redirect if unauthorized?
- [ ] **Flash Content**: Is there a split second where private content is visible during loading?
- [ ] **Role Check**: Does the logic correctly handle different user roles (Admin vs User vs Brand)?

## 📦 Data Handling
- [ ] **Loading States**: Are skeleton screens or spinners consistent with the `LovedBy` luxury aesthetic?
- [ ] **Error Handling**: Are try/catch blocks present for all async calls? Are user-friendly error messages shown?
- [ ] **Empty State**: Is there a high-quality "No items found" state with a clear CTA?
- [ ] **Race Conditions**: Does a new fetch correctly overwrite or cancel an old pending fetch?

## 🌊 Lifecycle & Effects
- [ ] **Dependecy Arrays**: Are `useEffect` dependencies correct? (No `eslint-disable-next-line`)
- [ ] **Cleanup**: Are `window.addEventListener` or `gsap.context` cleaned up?
- [ ] **Stale Closures**: Are callbacks using the latest state values?

## 🎭 Animations & Transitions
- [ ] **Navigation Race**: Does hitting the browser "Back" button mid-animation break anything?
- [ ] **Safety Reveal**: Does hidden content eventually show up if the animation trigger fails?
- [ ] **ScrollTrigger Health**: Are triggers refreshed when dynamic content changes the page height?

## 📱 Responsiveness & Memory
- [ ] **Memory Leaks**: Are there signs of growing listener counts on re-renders?
- [ ] **Network Usage**: Are assets (images/videos) lazy-loaded and optimized?
