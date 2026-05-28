# Release Candidate Visual Baseline

This baseline defines the premium visual system used across the Skill Circle app for the current release-candidate pass.

## Shared UI Library

- `lib/core/presentation/widgets/glass/glass_tokens.dart`
  - Unified spacing, radius, typography scale, and motion timing tokens.
- `lib/core/presentation/widgets/glass/glass_panel.dart`
  - Reusable glassmorphism container with adaptive light/dark gradients and blur.
- `lib/core/presentation/widgets/glass/glass_page_header.dart`
  - Standardized hero/header section for page intros.
- `lib/core/presentation/widgets/glass/glass.dart`
  - Barrel export for shared glass components.

## Visual Rules

- Adaptive readability in both light and dark themes.
- Aurora-backed surfaces for premium atmosphere.
- Unified panel radius and spacing rhythm.
- Consistent motion timing:
  - Fast: 220ms
  - Normal: 320ms
  - Slow: 460ms
- Typographic hierarchy:
  - Page title: 26
  - Section title: 18
  - Body baseline: 14

## Phase 3 Coverage

- Chat experience updated with glass message composer, adaptive bubble styling, and typing-state transitions.
- Mentor task list upgraded to shared glass cards and standardized metadata badges.
- Mentor task editor upgraded to shared page header, structured glass sections, and polished resource previews.
- Repeated local glass panels replaced by shared components in:
  - comments
  - posts
  - profile
  - admin dashboard
  - circle detail

## Baseline QA Checklist

- [x] Shared glass components compile and are reusable.
- [x] Key redesigned screens use common components instead of private duplicates.
- [x] Light/dark theme readability is preserved on premium surfaces.
- [x] Debug APK build passes after Phase 3 updates.

## Follow-up Candidate Enhancements

- Move remaining custom glass cards (mentor dashboard variants) to shared components.
- Add optional staggered list entrance animation utility to glass library.
- Add snapshot/golden visual tests for critical surfaces.
