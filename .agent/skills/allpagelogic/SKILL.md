---
name: allpagelogic
description: Systematic webpage logic auditing for robustness, data flow, and state consistency. Use when performing deep analysis of page logic or identifying complex edge case vulnerabilities.
---

# AllPageLogic Skill

You are an expert at deep-diving into the logical flows of a web application. Your goal is to move beyond UI/UX and focus on the "plumbing" of each page—ensuring that data, state, and side effects are handled robustly across all routes.

## 🎯 Goal
Identify and document logical gaps, race conditions, and state inconsistencies in any webpage profile.

## 🛑 Use Cases
- **USE WHEN**:
    - Navigating a complex application for the first time.
    - Auditing a specific page for robustness (e.g., after reports of intermittent failure).
    - Designing a new complex route with multi-step state.
    - Large refactors involving data fetching or auth guards.
- **DO NOT USE WHEN**:
    - Performing simple UI tweaks or CSS-only changes.
    - Basic documentation or static content updates.

## 🛠️ Implementation Rules

### 1. Route Discovery Protocol
- Always start by reading `App.tsx` or the main router file.
- Map the target page's entry conditions (Auth, Params, Redirects).

### 2. Data Flow Audit
- **Queries**: Identify all Supabase/API calls. Check for:
    - Loading/Error/Empty state handling.
    - Optimistic UI vs Server-truth synchronization.
    - Redundant fetching (Waterfalls).

### 3. State & Side-Effect Logic
- **useEffect Analysis**: Check dependency arrays for missing or redundant triggers.
- **Cleanup**: Ensure listeners, timers, and GSAP triggers are properly killed.
- **Transition Safety**: Verify that rapid navigation (Spamming "Back") doesn't break the UI.

### 4. Edge Case Pressure Test
- **Empty States**: What if the database returns `[]`?
- **Slow Connections**: How does the page handle high latency?
- **Unauthenticated**: Does the page leak data before the auth check completes?

## 📊 Auditing Report Template
Use this structure when reporting findings:
1. **Logical Overview**: High-level summary of the page's mechanics.
2. **Identified Issues**: Categorized by Severity (Critical/High/Medium/Low).
3. **Proposed Solutions**: Tactical fixes for each issue.
4. **Robustness Checklist**: Pass/Fail for common logic standards.

## 📄 References
- [Logic Checklist](file:///home/vaibhav/Desktop/Lb/LovedBy/.agent/skills/allpagelogic/references/logic_checklist.md)
