# 🛡️ Saheli — Women's Safety App
### Product Requirements Document (PRD)
**Hackathon:** WsCube Tech Mini Hackathon — Web Dev Category  
**Duration:** 24 Hours  
**Stack:** Flutter (Android-first) · No backend APIs required · Fully offline-capable  
**IDE:** Antigravity (Google's VS Code fork) with `.agent` skills  
**Alt IDE:** OpenCode with `/skills`  

---

## 🎯 Elevator Pitch

> *"Every 15 minutes, a woman in India reports a safety incident. Most had a phone in their hand. We built Saheli — because your phone should be your safest friend. It works when everything else fails."*

**Tagline:** *Your phone. Your shield. Always.*

---

## 💡 Core Philosophy

Saheli is not just a safety app — it is a **complete victim lifecycle tool**:

| Phase | What Saheli Does |
|-------|-----------------|
| **Before danger** | Journey mode, routine anomaly detection, guardian mode |
| **During danger** | SOS (multi-trigger), SMS fallback, scream detection, flashlight morse |
| **Evidence** | Audio recording, photo capture, evidence locker |
| **After danger** | Incident report PDF, legal rights info, FIR guidance |

---

## 🏗 Architecture Overview

```
saheli/
├── lib/
│   ├── main.dart
│   ├── app.dart                    # MaterialApp + localization setup
│   ├── core/
│   │   ├── constants/
│   │   │   ├── app_colors.dart
│   │   │   ├── app_strings.dart
│   │   │   └── legal_data.dart     # Hardcoded offline legal info
│   │   ├── services/
│   │   │   ├── location_service.dart
│   │   │   ├── sms_service.dart
│   │   │   ├── audio_service.dart
│   │   │   ├── contact_service.dart
│   │   │   └── notification_service.dart
│   │   └── utils/
│   │       ├── coordinate_math.dart   # Bearing deviation logic
│   │       └── pattern_analyzer.dart  # Typing/routine anomaly
│   ├── features/
│   │   ├── calculator_disguise/
│   │   ├── sos/
│   │   ├── fake_call/
│   │   ├── evidence_locker/
│   │   ├── journey_mode/
│   │   ├── guardian_mode/
│   │   ├── legal_info/
│   │   └── settings/
│   └── l10n/
│       ├── app_en.arb
│       ├── app_hi.arb
│       ├── app_ta.arb
│       ├── app_te.arb
│       ├── app_bn.arb
│       └── app_mr.arb
├── assets/
│   ├── audio/ringtone.mp3
│   └── data/heatmap_zones.json      # Static unsafe zone data
└── pubspec.yaml
```

---

## 📦 Flutter Packages Master List

```yaml
dependencies:
  flutter:
    sdk: flutter

  # Localization
  flutter_localizations:
    sdk: flutter
  intl: ^0.19.0

  # Location
  geolocator: ^11.0.0
  permission_handler: ^11.3.0

  # SMS (Android only)
  flutter_telephony: ^0.0.9+1        # Send SMS programmatically
  background_sms: ^0.0.4             # Background SMS

  # Storage
  shared_preferences: ^2.2.3         # Simple key-value local storage
  sqflite: ^2.3.3                    # Local SQLite for SOS history
  flutter_secure_storage: ^9.0.0     # Secure storage for PIN, contacts

  # Sensors
  sensors_plus: ^5.0.1               # Accelerometer for shake-to-SOS
  battery_plus: ^6.0.1               # Battery level monitoring

  # Audio
  record: ^5.1.2                     # Microphone recording
  audioplayers: ^6.0.0               # Play fake ringtone

  # Camera
  camera: ^0.11.0+2                  # Photo capture
  
  # PDF
  pdf: ^3.10.8                       # Incident report generation
  printing: ^5.12.0                  # Print/share PDF

  # Notifications
  flutter_local_notifications: ^17.2.2

  # UI / Overlays
  flutter_overlay_window: ^0.3.0     # Fake battery/shutdown overlay
  torch_light: ^1.1.0                # Flashlight control (Morse SOS)

  # TTS
  flutter_tts: ^4.0.2               # Voice read-aloud in Hindi/English

  # Calls
  url_launcher: ^6.3.0              # Auto-call via tel:// + WhatsApp deep link

  # Auth
  local_auth: ^2.2.0                # Biometric lock for evidence locker

  # Bluetooth (optional)
  flutter_blue_plus: ^1.32.12       # Bluetooth ping for Guardian Mode

  # Speech (optional, build last)
  speech_to_text: ^6.6.2            # Voice trigger "Saheli help"

  # Volume/Hardware buttons
  hardware_buttons: ^1.0.4           # Power button & volume triple-press
```

---

## 🔴 TIER 1 — CORE FEATURES (Hours 1–8, Build First)

### Feature 1: Calculator Disguise + Code Unlock

**What:** App looks exactly like a calculator. Typing a specific PIN (e.g. `2580=`) unlocks the real Saheli app.

**Why it wins:** Abusers checking the victim's phone see nothing suspicious. Judges immediately understand the real-world depth of this design decision.

**Implementation:**
```dart
// features/calculator_disguise/calculator_screen.dart
// Show standard calculator UI
// Listen to typed sequence via ValueNotifier<String>
// On match with stored PIN → Navigator.pushReplacement to HomeScreen
// Wrong pin 3x → wipe all data + reset to blank calculator
```

**Packages:** `flutter_secure_storage` (store PIN), `shared_preferences` (fail count)

**Pitch line:** *"She can check her phone like normal. Nobody knows Saheli is even there."*

---

### Feature 2: Triple Power Button SOS

**What:** Press the power button 3 times rapidly → SOS triggers silently.

**Implementation:**
```dart
// Use hardware_buttons package
// Listen to power button events
// Increment counter, reset after 1.5 seconds
// On count == 3 → trigger SOS flow
```

**Packages:** `hardware_buttons`

> [!NOTE]
> Requires `android.permission.RECEIVE_BOOT_COMPLETED` and a foreground service to listen in background. Scaffold this in `AndroidManifest.xml` early.

---

### Feature 3: Offline SMS SOS with GPS Coordinates

**What:** SOS sends SMS to 5 contacts with last known GPS as Google Maps link. Works in airplane mode.

**SMS Format (per language):**
```
[Hindi] 🆘 मुझे खतरा है! मेरी आखिरी लोकेशन: https://maps.google.com/?q=LAT,LNG — Saheli App
[English] 🆘 I am in DANGER! My last location: https://maps.google.com/?q=LAT,LNG — Saheli App
```

**Implementation:**
```dart
// services/sms_service.dart
// 1. Try geolocator.getCurrentPosition()
// 2. If fails → use cached coordinates from shared_preferences
// 3. Format message in user's selected language
// 4. Loop through contacts list → send SMS to each
// 5. If SMS also fails → write to local log
```

**Packages:** `flutter_telephony`, `geolocator`, `shared_preferences`

**Location Cache:** Update every 60 seconds via background timer, store in `shared_preferences`.

---

### Feature 4: Fake Call Screen

**What:** Tapping "Fake Call" shows a realistic incoming call UI with pre-set contact name and photo. Plays a ringtone. Help escape danger by pretending to receive a call.

**Implementation:**
```dart
// features/fake_call/fake_call_screen.dart
// Full screen overlay mimicking Android call UI
// Play ringtone via audioplayers
// Pre-set caller name stored in shared_preferences
// "Decline" returns to disguised calculator
```

**Packages:** `audioplayers`, `flutter_overlay_window`

**Demo moment:** Ask someone to "call" on stage using this feature. Judges laugh then immediately understand the use case.

---

### Feature 5: Shake-to-SOS with Adjustable Sensitivity

**What:** Shake the phone rapidly 3× → SOS triggers. Sensitivity (low/medium/high) set in Settings.

**Implementation:**
```dart
// Accelerometer stream from sensors_plus
// Calculate magnitude: sqrt(x² + y² + z²)
// Threshold: Low=15, Medium=12, High=9 (m/s²)
// Debounce: 500ms between shakes
// 3 shakes in 2 seconds → trigger SOS
```

**Packages:** `sensors_plus`

**Demo moment:** Shake phone on stage → SMS arrives on another phone in the room.

---

## 🟠 TIER 2 — HIGH-IMPACT DIFFERENTIATORS (Hours 8–16)

### Feature 6: Dead Man's Switch

**What:** App sends silent notification: "Are you safe?" every 10 mins. If no response in 60 seconds → auto-SOS.

**Implementation:**
```dart
// flutter_local_notifications repeating notification
// Action buttons: "✅ Safe" | "🆘 HELP"
// Foreground service timer
// On timeout → trigger SOS flow
```

**Pitch line:** *"Borrowed from nuclear submarines. Adapted to protect women in India."*

---

### Feature 7: Scream Detection

**What:** Mic monitors ambient sound. A sudden spike above threshold (e.g., 80dB) auto-triggers SOS.

**Implementation:**
```dart
// record package → amplitude stream
// Monitor amplitude every 500ms
// If amplitude > threshold for 300ms → trigger SOS
// Show 3-second countdown with cancel option (false positive guard)
```

**Packages:** `record`

**Demo moment:** Scream near the phone on stage → SOS fires. Room goes silent.

> [!IMPORTANT]
> Always show a 3-second cancel countdown after scream detection to prevent false positives. Demonstrate the cancel too — judges will ask about it.

---

### Feature 8: Flashlight Morse SOS

**What:** SOS triggers → phone flashlight blinks S-O-S (· · · — — — · · ·) on loop.

**Implementation:**
```dart
// torch_light package
// SOS pattern: 3×(short 200ms ON, 200ms OFF) + 3×(long 600ms ON, 200ms OFF) + 3×(short)
// Loop until user cancels or contacts respond
```

**Packages:** `torch_light`

**Pitch line:** *"Ancient maritime distress signal. Now in every woman's pocket."*

---

### Feature 9: Fake Low Battery / Fake Shutdown Screen

**What:** One tap → phone shows a perfectly realistic "device shutting down" black screen overlay. Phone is secretly recording audio and tracking location underneath.

**Implementation:**
```dart
// flutter_overlay_window → full black overlay with shutdown animation
// Under the hood: record package starts audio recording
// geolocator continues GPS tracking
// Triple power-press cancels the disguise
```

**Packages:** `flutter_overlay_window`, `record`

**Pitch line:** *"The attacker thinks the phone is off. Saheli is still recording everything."*

---

### Feature 10: Evidence Locker

**What:** Every SOS event auto-creates a timestamped evidence folder: audio recording, GPS log, front+back camera photos. Locked behind biometrics.

**Structure:**
```
/saheli_evidence/
└── 2026-02-20_15-37-12/
    ├── audio_recording.m4a
    ├── front_camera.jpg
    ├── back_camera.jpg
    ├── gps_log.txt
    └── event_summary.txt
```

**Packages:** `camera`, `record`, `local_auth`, `sqflite`

---

### Feature 11: Battery-Aware SOS

**What:** If battery drops below 15% → automatically SMS all contacts with last known location.

**Implementation:**
```dart
// battery_plus → listen to battery level stream
// On level < 15 AND discharging → trigger SMS (not full SOS, just location SMS)
// Message: "Saheli alert: [Name]'s phone battery is critical. Last location: [link]"
```

**Pitch line:** *"Most attacks happen when victims can't call for help — often because their phone dies."*

---

### Feature 12: Audio Recording → Evidence on SOS

**What:** SOS trigger → silent 15-second audio recording saves to Evidence Locker. SMS to contacts says: *"Audio evidence captured. Open Saheli Evidence Locker."*

**Packages:** `record`

> [!NOTE]
> Do NOT attempt to send the audio file automatically via SMS or WhatsApp — file size and API restrictions make this unreliable. Save locally, notify contacts to check the locker. This is actually a more trustworthy legal approach.

---

### Feature 13: Safe Arrival Confirmation

**What:** Before a journey, tap "I'm going home." When movement stops at destination → auto-SMS to contacts: *"वो सुरक्षित पहुंच गई / She arrived safely."*

**Implementation:**
```dart
// geolocator stream → detect movement stop (speed < 0.5 m/s for 60s)
// Compare to expected destination (set at journey start)
// Auto-trigger safe arrival SMS
```

**Pitch line:** *"So your mother stops worrying the moment you get home."*

---

### Feature 14: Wrong-PIN Photo Capture

**What:** 3 wrong PINs entered on the calculator disguise → front camera silently takes a photo and saves it to Evidence Locker.

**Implementation:**
```dart
// Track failed PIN attempts in shared_preferences
// On attempt 3 → CameraController.takePicture() with minimal UI
// Save to evidence folder with timestamp
// Reset counter, show blank calculator
```

**Packages:** `camera`

---

## 🟡 TIER 3 — WOW FACTORS (Hours 16–20)

### Feature 15: Journey Mode with Deviation Alert

**What:** Tap "I'm going home" → app records starting bearing. If movement deviates >45° from expected direction for >2 minutes → auto-SOS.

**No Maps API needed.** Pure coordinate math:

```dart
// Calculate bearing between start and current using:
// atan2(sin(Δlng)×cos(lat2), cos(lat1)×sin(lat2)−sin(lat1)×cos(lat2)×cos(Δlng))
// If |bearing_deviation| > 45° for > 120 seconds → trigger SOS
```

**Pitch line:** *"If someone is taking her somewhere she didn't choose, Saheli knows."*

---

### Feature 16: One-Tap Legal Information (Offline)

**What:** Post-incident screen showing: how to file FIR, women's rights during arrest, national helplines — all stored locally in JSON.

**Key Helplines to include:**
| Service | Number |
|---------|--------|
| Women Helpline | 1091 |
| Police | 100 |
| Emergency | 112 |
| Nirbhaya Helpline | 181 |
| Cyber Crime | 1930 |

**Pitch line:** *"Every other safety app tells someone you're in danger. Saheli makes sure you survive it, prove it, and recover from it."*

---

### Feature 17: Incident Report PDF Generator

**What:** After SOS event, one tap generates a formatted PDF with: timestamp, GPS coordinates, event duration, trigger method, contacts notified, audio evidence reference.

**Packages:** `pdf`, `printing`

**Pitch line:** *"Hand this to the police. Right now. No waiting."*

---

### Feature 18: Guardian Mode

**What:** Parent/friend opens Saheli → enters "Guardian Mode" → sees simple screen: green = safe (last check-in X mins ago) / red = SOS triggered. Syncs via Bluetooth when nearby.

**Packages:** `flutter_blue_plus`

---

### Feature 19: Smart Contact Priority Learning

**What:** App tracks which contact responds fastest to check-ins over time. Auto-reorders contacts so fastest responder gets SOS first.

**Implementation:** Simple response time tracking in `shared_preferences`. No ML needed.

**Pitch line:** *"Machine learning without machine learning — adaptive safety."*

---

### Feature 20: Multilingual Voice Read-Aloud on SOS

**What:** When SOS triggers → phone speaker announces loudly in Hindi + English: *"Emergency alert sent. Help is on the way."*

**Dual purpose:** Reassures victim AND alerts bystanders.

**Packages:** `flutter_tts`

---

## 🟢 TIER 4 — POLISH (Hours 20–23)

### Feature 21: SOS History & Timeline

Timeline of all SOS events with: timestamp, GPS, trigger method, duration. Stored in SQLite. Forensic value for police.

### Feature 22: Personalized SOS Messages Per Contact

Mom gets Hindi message. Friend gets English with Maps link. Emergency contact gets formal timestamped message. All pre-configured in onboarding.

### Feature 23: Periodic Safety Pulse (Journey Mode)

Every 30 minutes during journey → silent SMS to one contact with updated GPS. Breadcrumb trail for police if needed.

### Feature 24: Sensitivity Settings Panel

User-adjustable: shake sensitivity, scream threshold, dead man's switch interval, countdown duration. Shows maturity of product thinking to judges.

### Feature 25: App Lock + Data Wipe

Wrong biometric 3× → auto-wipe all personal data → relaunch as blank calculator. Protects victim from abusive partner checking phone.

---

## 🌐 Localization Plan (6 Languages)

**Languages:** Hindi · English · Tamil · Telugu · Bengali · Marathi

**Covers:** ~900 million Indians (use this stat in pitch)

### Critical Strings to Translate

| Key | Hindi | Tamil | Telugu | Bengali | Marathi |
|-----|-------|-------|--------|---------|---------|
| sos_help | मुझे बचाओ | என்னை காப்பாற்றுங்கள் | నన్ను రక్షించండి | আমাকে সাহায্য করুন | मला वाचवा |
| in_danger | मैं खतरे में हूं | நான் ஆபத்தில் இருக்கிறேன் | నేను ప్రమాదంలో ఉన్నానుఁ | আমি বিপদে আছি | मी धोक्यात आहे |
| last_location | मेरी लोकेशन | என் இருப்பிடம் | నా స్థానం | আমার অবস্থান | माझे स्थान |
| arrived_safe | वो सुरक्षित पहुंच गई | அவள் பாதுகாப்பாக வந்தாள் | ఆమె సురక్షితంగా చేరుకుంది | সে নিরাপদে পৌঁছেছে | ती सुरक्षित पोहोचली |
| sos_sent | आपातकालीन SOS भेजा | அவசர SOS அனுப்பப்பட்டது | అత్యవసర SOS పంపబడింది | জরুরি SOS পাঠানো হয়েছে | आपत्कालीन SOS पाठवला |

**Translate only these 5 screens** (rest can be English):
1. SOS trigger screen
2. Onboarding / Contact setup
3. Fake call screen
4. Legal info screen
5. Settings screen

**Time budget:** ~3 hours total for all 6 languages.

**Demo moment:** Switch language to Tamil live on stage → switch to Bengali → back to Hindi. *"Because a woman in Chennai and a woman in Kolkata both deserve to be safe — in their own language."*

---

## ⏱ 24-Hour Build Roadmap

### Hour 0–1: Setup
- [ ] Create Flutter project: `flutter create saheli`
- [ ] Add all packages to `pubspec.yaml`
- [ ] Configure `AndroidManifest.xml` permissions:
  - `SEND_SMS`, `READ_PHONE_STATE`, `CAMERA`, `RECORD_AUDIO`
  - `ACCESS_FINE_LOCATION`, `ACCESS_BACKGROUND_LOCATION`
  - `RECEIVE_BOOT_COMPLETED`, `FOREGROUND_SERVICE`
- [ ] Set up `l10n/` folder with ARB files for all 6 languages
- [ ] **Start pitch deck NOW** — run parallel the entire 24hrs

### Hour 1–4: Core SOS Engine
- [ ] `location_service.dart` — GPS + 60s background cache
- [ ] `sms_service.dart` — send to multiple contacts offline
- [ ] `contact_service.dart` — store/retrieve 5 contacts locally
- [ ] `sos_screen.dart` — big red button, 3s hold trigger
- [ ] Test SMS delivery end-to-end on real device

### Hour 4–6: Calculator Disguise
- [ ] `calculator_screen.dart` — functional calculator UI
- [ ] PIN unlock sequence → navigate to real home
- [ ] Wrong PIN 3× → photo capture + data wipe

### Hour 6–10: Trigger Methods
- [ ] Shake-to-SOS (sensors_plus)
- [ ] Triple power button (hardware_buttons)
- [ ] Dead Man's Switch (local notifications)
- [ ] Scream detection (record amplitude)

### Hour 10–13: Stealth Features
- [ ] Fake call screen (audioplayers + overlay UI)
- [ ] Fake low battery/shutdown overlay
- [ ] Evidence locker (camera + record + biometric lock)

### Hour 13–16: Smart Features
- [ ] Journey Mode + deviation alert (coordinate math)
- [ ] Safe arrival confirmation
- [ ] Battery-aware SOS
- [ ] Flashlight Morse SOS

### Hour 16–18: Delight Features
- [ ] One-tap legal info (hardcoded JSON)
- [ ] Incident report PDF generator
- [ ] Voice read-aloud on SOS (flutter_tts)
- [ ] Guardian Mode (Bluetooth ping)

### Hour 18–20: Language & Polish
- [ ] Translate critical strings to all 6 languages
- [ ] Language selector in settings
- [ ] Sensitivity settings panel
- [ ] SOS history timeline UI
- [ ] Smart contact priority reordering

### Hour 20–22: Presentation
- [ ] Record 3-min demo video (offline airplane mode demo)
- [ ] Finalize pitch deck (structure below)
- [ ] Prepare backup APK on multiple devices

### Hour 22–24: Final Buffer
- [ ] Test every trigger method end-to-end
- [ ] Fix critical bugs only
- [ ] Rehearse pitch 2× with team
- [ ] Submit + breathe

---

## 🎤 Pitch Structure (3 Minutes)

| Segment | Duration | Content |
|---------|----------|---------|
| **The Hook** | 20s | Real stat + news headline on screen |
| **The Demo** | 90s | Live: shake → SMS arrives. Airplane mode → SMS still arrives. Show fake battery screen. Show PDF report. |
| **The Story** | 20s | "Before → During → After: survive it, prove it, recover from it" |
| **The Scale** | 20s | 900M Indians, 6 languages, 25 features, zero internet required |
| **The Ask** | 30s | What you'd build next (WhatsApp integration, ML scream model, wearable) |

**Opening line:**
> *"Every 15 minutes, a woman in India reports a safety incident. Most had a phone in their hand. We built Saheli — because your phone should be your safest friend."*

**3-part story:**
> *"Danger → Survive it. Evidence → Prove it. Legal info → Recover from it."*

---

## 🤖 Using Antigravity Agent Skills

> Use these prompts **verbatim** in the Antigravity Manager panel. The agents will read your `.agent/skills/` folder automatically.

### Prompt 1: Project Scaffold
```
@flutter-skill scaffold a new Flutter project called "saheli" with the 
package name com.saheli.app. Set up localization for hi, en, ta, te, bn, mr 
using flutter_localizations and intl. Create the folder structure from the PRD.
Add all packages from pubspec.yaml in the PRD.
```

### Prompt 2: Core SOS Engine
```
@flutter-skill @backend-specialist build the SOS engine for Saheli:
1. LocationService that caches GPS every 60s to shared_preferences
2. SMSService that sends to a List<Contact> using flutter_telephony with Google Maps link
3. Build the SOS home screen with a red hold-to-trigger button (3s hold pattern)
Use the architecture from the PRD. Android-only, offline-first.
```

### Prompt 3: Calculator Disguise
```
@flutter-skill build a fully functional calculator UI for Saheli's disguise screen.
Listen for the input sequence "2580=" — on match, navigate to the real home screen.
Track wrong attempts in shared_preferences. On 3 wrong attempts, trigger camera capture 
and clear all app data.
```

### Prompt 4: Sensor Triggers
```
@flutter-skill implement three SOS trigger methods for Saheli:
1. Shake: use sensors_plus accelerometer, threshold configurable (9/12/15 m/s²), 3 shakes in 2s
2. Power button: use hardware_buttons, 3 presses in 2s
3. Scream detection: use record package amplitude stream, threshold 80dB, 3s cancel countdown
All three call the same SOS trigger function.
```

### Prompt 5: Evidence Locker
```
@flutter-skill build an Evidence Locker feature for Saheli:
- On SOS trigger: record 15s audio, take front+back camera photos, save GPS log
- Save all to /saheli_evidence/[timestamp]/ folder
- List all incidents in a timeline UI secured by local_auth biometric
- Generate a PDF report using the pdf package with all evidence metadata
```

### Prompt 6: Localization
```
@flutter-skill add complete localization to Saheli for 6 languages: 
en, hi, ta, te, bn, mr. Translate these keys using the PRD translation table:
sos_help, in_danger, last_location, arrived_safe, sos_sent.
Add a language dropdown in Settings that persists to shared_preferences.
```

---

## 💻 Using OpenCode with `/skills`

If using OpenCode instead of Antigravity, invoke skills via slash commands:

```bash
# In OpenCode terminal/chat:
/skills flutter     # Activate Flutter skill rules
/skills clean-code  # Enforce clean code standards
/skills database-design  # For local SQLite schema design
```

**Recommended OpenCode workflow:**
1. `/skills flutter` → generate project scaffold
2. Write features one file at a time, referencing PRD
3. `/skills clean-code` before committing each feature
4. `/skills testing-patterns` to generate unit tests for SOS logic

---

## ✅ Minimum Winning Feature Set

> If time runs out, shipping these 8 features flawlessly beats all 25 features half-broken:

| # | Feature | Demo Moment |
|---|---------|-------------|
| 1 | One-tap SOS + SMS | Core |
| 2 | Offline SMS fallback | Airplane mode on stage |
| 3 | Calculator disguise | Open hidden app live |
| 4 | Fake call screen | "Call" someone on stage |
| 5 | Shake-to-SOS | Shake phone → SMS arrives in room |
| 6 | Evidence locker | Show timestamped folder |
| 7 | Fake battery screen | Black screen → still recording |
| 8 | One-tap legal info | Show FIR guide + 1091 helpline |

---

## 🚀 Technical Constraints & Risk Mitigation

| Risk | Mitigation |
|------|-----------|
| SMS permissions denied on demo phone | Pre-grant all permissions before hackathon, test on 2 devices |
| Scream detection false positives | Always show 3s countdown with cancel button |
| Voice trigger ("Saheli help") unreliable | Build last, mark as "beta" in demo |
| WhatsApp auto-send blocked | Use url_launcher deep link, label as "one-tap WhatsApp SOS" |
| Bluetooth Guardian Mode limited range | Demo on 2 phones side by side, explain the concept clearly |
| Bad hackathon WiFi | Everything is offline-first — this is your competitive advantage |
| flutter_telephony Android-only | Demo on Android. Mention iOS version planned post-hackathon |

---

*Built with ❤️ for every woman who deserves a phone that fights for her.*
