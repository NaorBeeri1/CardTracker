# 🎸 Keepsake: CardTracker

A high-performance cross-platform mobile application built with **Flutter** and **Firebase** for cataloging, tracking, and managing a 300-card Michael Jackson collection. Designed with robust state management, real-time cloud synchronization, and strict parallel variation exclusivity logic.

---

## 🚀 Key Features

* **Master Checklist:** Full tracking system across all 300 cards in the collection, segmented by rarity tiers, sets, and eras (including the *Bad World Tour* collection).
* **Parallel Variation Management:** Implements strict mutual exclusivity and validation rules for rare parallel variants (preventing conflicting attribute states, such as simultaneous base/variant cross-selection).
* **Serial Number Tracking:** Custom input validation for tracking rare numbered parallel variants.
* **Real-Time Firebase Cloud Sync:** Powered by Firebase Authentication and Cloud Firestore for secure, real-time multi-device state synchronization.
* **Collector Level-Ranking System:** Gamified progression tracking that updates collector ranks as completion percentages scale upward.
* **Instant-Access Guest Mode:** Built-in guest authentication bypass allowing reviewers and testers to log in instantly with a single tap to explore the full checklist and UI without manual registration.

---

## 🛠️ Tech Stack & Architecture

* **Frontend:** Flutter (Dart), Material Design UI
* **Backend & Auth:** Firebase Authentication, Cloud Firestore
* **State Management:** Provider / Reactive Flutter state architecture
* **Platform Targets:** Android, iOS, and Web-compatible build pipelines

---

## 📦 Getting Started & Local Execution

To run this project locally on your machine or mobile emulator:

1. **Clone the repository:**
   ```bash
   git clone [https://github.com/NaorBeeri1/CardTracker.git](https://github.com/NaorBeeri1/CardTracker.git)
   cd CardTracker
