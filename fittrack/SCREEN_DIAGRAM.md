# FitTrack App - Screen Flow Diagram

## Overview
This document shows all screens in the FitTrack app and how users navigate between them.

---

## Screen Flow Diagram

```
                    ┌─────────────────┐
                    │  Start Screen   │
                    └────────┬────────┘
                             │
                             ▼
                    ┌─────────────────┐
                    │  Login Screen   │◄─────────────────────┐
                    └────────┬────────┘                      │
                             │                               │
              ┌──────────────┴──────────────┐                │
              │                             │                │
              ▼                             ▼                │
    ┌─────────────────┐           ┌─────────────────┐        │
    │  Signup Screen  │           │   Home Screen   │        │
    └────────┬────────┘           └────────┬────────┘        │
             │                             │                 │
             ▼                             │                 │
    ┌─────────────────┐                    │                 │
    │   Assessment    │                    │                 │
    │     Screen      │────────────────────┘                 │
    └─────────────────┘                                      │
                                                             │
                                                             │
                    ┌─────────────────┐                      │
                    │   Home Screen   │                      │
                    └────────┬────────┘                      │
                             │                               │
         ┌───────────────────┼───────────────────┐           │
         │                   │                   │           │
         ▼                   ▼                   ▼           │
┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐  │
│   Analytics     │ │  Workout List   │ │    Settings     │  │
│    Screen       │ │    Screen       │ │     Screen      │  │
└─────────────────┘ └────────┬────────┘ └────────┬────────┘  │
                             │                   │           │
                             ▼                   │           │
                    ┌─────────────────┐          │           │
                    │Exercise Detail  │          │           │
                    │    Screen       │          │           │
                    └─────────────────┘          │           │
                                                 │           │
                          ┌──────────────────────┼───────┐   │
                          │                      │       │   │
                          ▼                      ▼       │   │
                 ┌─────────────────┐    ┌─────────────┐  │   │
                 │   Edit Plan     │    │   Change    │  │   │
                 │    Screen       │    │  Password   │  │   │
                 └─────────────────┘    └─────────────┘  │   │
                                                         │   │
                                                         │   │
                                               (Logout)──┴───┘
```

---

## Simplified Flow

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   Start     │────▶│   Login     │────▶│    Home     │
│   Screen    │     │   Screen    │     │   Screen    │
└─────────────┘     └──────┬──────┘     └──────┬──────┘
                           │                   │
                           ▼                   │
                    ┌─────────────┐            │
                    │   Signup    │            │
                    │   Screen    │            │
                    └──────┬──────┘            │
                           │                   │
                           ▼                   │
                    ┌─────────────┐            │
                    │ Assessment  │────────────┘
                    │   Screen    │
                    └─────────────┘
```

---

## Workout Flow

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│    Home     │────▶│  Workout    │────▶│  Exercise   │
│   Screen    │     │    List     │     │   Detail    │
└─────────────┘     └─────────────┘     └──────┬──────┘
                           ▲                   │
                           │                   │
                           └───────────────────┘
                              (Back after Done)
```

---

## Settings Flow

```
                    ┌─────────────┐
              ┌────▶│  Edit Plan  │
              │     │   Screen    │
              │     └─────────────┘
┌─────────────┐
│  Settings   │
│   Screen    │
└──────┬──────┘
       │        ┌─────────────┐
       └───────▶│   Change    │
                │  Password   │
                └─────────────┘
```

---

## Screen List

| Screen | File | Description |
|--------|------|-------------|
| Start Screen | `start_screen.dart` | Splash with logo, tap to skip |
| Login Screen | `login_screen.dart` | Username & password login |
| Signup Screen | `signup_screen.dart` | New user registration |
| Assessment Screen | `assessment_screen.dart` | Plan, categories, schedule |
| Home Screen | `home_screen.dart` | Dashboard with 3 tabs |
| Analytics Screen | `analytics_screen.dart` | Workout stats & charts |
| Settings Screen | `settings_screen.dart` | Profile & app settings |
| Workout List Screen | `workout_list_screen.dart` | Exercise card grid |
| Exercise Detail Screen | `exercise_detail_screen.dart` | Instructions & done |
| Edit Plan Screen | `edit_plan_screen.dart` | Modify workout plan |
| Change Password Screen | `change_password_screen.dart` | Update password |

---

## File Structure

```
lib/ui/
├── start_screen.dart
└── pages/
    ├── authentication/
    │   ├── login_screen.dart
    │   └── signup_screen.dart
    ├── assessment/
    │   └── assessment_screen.dart
    ├── home/
    │   └── home_screen.dart
    ├── workout/
    │   ├── workout_list_screen.dart
    │   └── exercise_detail_screen.dart
    ├── analytics/
    │   └── analytics_screen.dart
    └── settings/
        ├── settings_screen.dart
        ├── edit_plan_screen.dart
        └── change_password_screen.dart
```
