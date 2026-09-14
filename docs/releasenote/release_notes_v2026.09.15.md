### 💖 Support Our Work

As an open-source, community-funded project, we operate on a very limited budget. If LTvLauncher helps you daily, please consider supporting us on [GitHub Sponsors](https://github.com/sponsors/LeanBitLab) or [Open Collective](https://opencollective.com/leanbitlab-org). Sharing LTvLauncher with friends and family makes a huge difference!

## 🚀 What's New in v2026.09.15

### 🚑 Critical Fixes & Stability
- **Startup Infinite Loading Screen Resolved (#145)**:
  - Fixed an unhandled null exception during category sorting (`AppsService.sortCategory`) that caused the app to hang permanently on the "Loading" splash screen after updates or backup restores.
  - Implemented automatic, self-healing database repair (`_repairOrphanedAppCategories`) to restore missing category relationships in SQLite for orphaned apps.
  - Added robust null-safe fallback sorting so missing orders never crash the launcher.
- **Android 7.1 (Nougat) Startup Crash Prevented (#144)**:
  - Safely isolated Android 8.0+ Oreo APIs (`TvContract.WatchNextPrograms`) so older Android TV and tablet devices running Android 7.1 (API 25) launch without crashes.
  - Added observer registration lifecycle tracking to avoid illegal unregister calls.
  - Handled program queries and deletion safely with zero unsupported API access on API < 26.
- **Proactive Orphan Prevention on Section Deletion**:
  - Deleting a custom section now automatically migrates apps with no other category into default categories (`TV Apps` or `Non-TV Apps`) before the category is destroyed.

### ✨ Enhancements & Refinements
- **Independent Playback Percentage Badge**:
  - Added a dedicated setting under Continue Watching settings to toggle playback percentage badges completely independently of progress bars.
- **Smart Program Description Fallbacks**:
  - Query long description and episode title as intelligent fallbacks when short descriptions are missing or duplicate the program title.
- **UI & Navigation Polish**:
  - Darkened Continue Watching card surfaces for better OLED contrast.
  - Fixed D-pad UP remote navigation when Continue Watching is placed as the second section row.

## 📦 Downloads (Choose Your Architecture)

| File | Target Devices | Architecture |
|:---|:---|:---|
| **`LTvLauncher-universal-release.apk`** | All Android TV & Fire TV devices (Universal) | Universal |
| **`LTvLauncher-arm64-v8a-release.apk`** | Chromecast with Google TV, Nvidia Shield, modern 64-bit Android TVs | 64-bit ARM (`arm64-v8a`) |
| **`LTvLauncher-armeabi-v7a-release.apk`** | Fire TV Stick (Lite, 4K, 4K Max), older smart TVs | 32-bit ARM (`armeabi-v7a`) |
