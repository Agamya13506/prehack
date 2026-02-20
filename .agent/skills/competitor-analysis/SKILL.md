---
name: competitor-analysis
description: Systematic decomposition of competitor products into actionable engineering specifications.
version: 1.0.0
---

# Competitor Analysis Skill

This skill enables the agent to reverse-engineer and analyze competitor products (websites, apps, codebases) to guide development.

## 🎯 Purpose
To transform observations of competitor products into concrete, implementable engineering tasks, ensuring parity or superiority ("Pro Max").

## 🛠️ process

### 1. Deconstruction (The "What")
- **Visuals**: Analyze layout, color palette, typography, whitespace, and "vibe".
- **Features**: List core functionalities (e.g., "Infinite Marquee", "Pinned Hero").
- **UX**: Map user flows and interactions (hover states, transitions).
- **Tech**: Identify likely libraries (GSAP, Framer Motion, Radix UI) based on behavior.

### 2. Gap Analysis (The "Delta")
- Compare competitor feature set vs. current project state.
- Identify "Table Stakes" (Must Haves) vs. "Delighters" (Nice to Haves).
- Flag "Pro Max" opportunities: Where can we be *better*? (e.g., smooth scroll vs. native, static vs. interactive).

### 3. Implementation Spec (The "How") 
- Convert findings into: 
    - **Component Specs**: Props, state, variants.
    - **Styling Rules**: Tailwind classes, animations.
    - **Logic**: Data structures, hooks, API needs.

## 📋 output_format

When asked to "analyze [competitor]", produce a **Competitor Breakdown Artifact**:

### [Competitor Name] Analysis

#### 1. Core DNA
- **Aesthetic**: [e.g., Minimal, Brutalist, Corporate]
- **Key Differentiator**: [e.g., Speed, Animation, Simplicity]

#### 2. Feature Breakdown

| Feature | Competitor Implementation | Our Implementation Strategy | "Pro Max" Upgrade |
| :--- | :--- | :--- | :--- |
| [Feature Name] | [Description] | [React/Tailwind approach] | [Enhancement] |

#### 3. Visual Replication Guide
- **Colors**: [Hex codes]
- **Type**: [Font families/weights]
- **Spacing**: [Tight/Loose]
- **Motion**: [Fast/Bouncy/Smooth]

## 🤖 rules
1.  **Don't Copy-Paste**: Analyze the *logic* and *design patterns*, then re-implement using our tech stack (Tailwind/React).
2.  **Elevate, Don't Clone**: Always look for the "Pro Max" angle. If they use a static image, can we use a video or 3D object?
3.  **Focus on "Why"**: Why does their design work? (e.g., "High contrast guides the eye to the CTA").
