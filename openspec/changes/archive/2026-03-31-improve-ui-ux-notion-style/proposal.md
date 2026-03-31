## Why

The current DevVault UI, while functional, lacks the clean, distraction-free experience that modern productivity tools like Notion provide. Users need a workspace that feels calm, organized, and efficient — where content takes priority over chrome. A minimalist Notion-inspired redesign will reduce visual noise, improve information hierarchy, and make daily interactions feel effortless.

## What Changes

- **Typography system**: Replace mixed font weights with a cleaner hierarchy using Inter with tighter letter-spacing and reduced weight range (400/500/600 only), matching Notion's editorial feel
- **Layout simplification**: Remove heavy borders, stat cards, and bento grid from dashboard; replace with clean list-based navigation and content-first views
- **Sidebar redesign**: Narrower sidebar with minimal icons, subtle hover states, and no heavy background fills — closer to Notion's workspace navigation
- **Top bar simplification**: Remove inactive filter tabs, reduce search bar prominence, streamline the breadcrumb into a simple page title
- **Card and list components**: Replace bordered cards with subtle hover-highlighted rows; use whitespace instead of borders for separation
- **Color palette refinement**: Reduce color usage to near-monochrome with a single accent; remove bright accent colors from BentoCard stat widgets
- **Dialog and modal redesign**: Simplify dialogs with less chrome, flatter structure, and more breathing room
- **Empty states**: Add Notion-style empty states with gentle prompts and call-to-action buttons
- **Animation polish**: Add subtle page transitions and micro-interactions (fade-in lists, smooth sidebar hover)

## Capabilities

### New Capabilities
- `notion-typography`: Clean typography hierarchy with editorial-style spacing, reduced font weights, and consistent scale
- `notion-layout`: Minimalist layout system prioritizing whitespace, content-first views, and reduced visual chrome
- `notion-components`: Redesigned sidebar, list rows, dialogs, and empty states following Notion's interaction patterns
- `micro-interactions`: Subtle animations for hover states, list transitions, and page navigation

### Modified Capabilities
<!-- No existing spec-level requirements changing — this is a visual/UX refinement only -->

## Impact

- **Affected files**: `lib/theme/app_theme.dart`, `lib/screens/dashboard_screen.dart`, `lib/screens/lock_screen.dart`, all view widgets in `lib/screens/`
- **Dependencies**: No new dependencies needed — uses existing `google_fonts`, `flutter_animate`, `lucide_icons`
- **Breaking changes**: None — purely visual/UX changes, no API or data model modifications
- **Platform**: Desktop-focused (Windows), but changes remain responsive-compatible
