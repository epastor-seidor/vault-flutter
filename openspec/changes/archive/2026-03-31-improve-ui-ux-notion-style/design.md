## Context

DevVault is a Flutter desktop application for managing credentials, notes, and tasks with local encrypted storage (Hive). The current UI uses a "Stitch Design System" with a muted earth-tone palette but suffers from visual clutter: heavy borders, bento grid dashboards, stat cards, prominent filter tabs, and inconsistent spacing. The app already uses Material 3, Google Fonts (Inter), Lucide Icons, and flutter_animate — providing a solid foundation for a Notion-inspired redesign without new dependencies.

Constraints:
- Desktop-first (Windows) but must remain responsive
- No new external dependencies
- Existing state management (Riverpod) and data models stay unchanged
- Dark/light theme support must be preserved

## Goals / Non-Goals

**Goals:**
- Achieve a clean, content-first UI matching Notion's minimalist aesthetic
- Reduce visual noise by replacing borders with whitespace and subtle hover states
- Establish a consistent typography hierarchy (400/500/600 weights only)
- Simplify navigation with a narrower, icon-forward sidebar
- Improve perceived performance with subtle micro-animations
- Create reusable widget patterns (list rows, empty states, dialogs)

**Non-Goals:**
- No changes to data models, storage, or business logic
- No new features — purely visual/UX refinement
- No mobile-specific optimizations (desktop-first)
- No theme system overhaul — refine existing tokens, don't replace

## Decisions

### 1. Typography: Tighter scale, fewer weights
**Decision:** Use Inter with only 400 (body), 500 (medium), 600 (semibold) weights. Title sizes: 24px (page), 18px (section), 14px (body). Line height 1.5 for body, 1.2 for titles. Negative letter-spacing (-0.02em) on titles for editorial feel.

**Why:** Notion's readability comes from restrained typography. The current code uses w700/w800/w900 which creates visual heaviness. Reducing to 3 weights creates hierarchy through size and spacing, not weight.

**Alternatives considered:**
- Keep current weights but reduce sizes → still feels heavy
- Switch to a different font (e.g., IBM Plex Sans) → Inter is already integrated and well-suited

### 2. Layout: Whitespace over borders
**Decision:** Remove most borders; use 16-24px padding and 8-12px gaps for separation. List items use hover background fills (surface-container-low) instead of outlined cards.

**Why:** Notion's signature look comes from generous whitespace and subtle hover states. Borders create visual noise and fragment the page. Background color shifts on hover provide clear affordance without chrome.

**Alternatives considered:**
- Keep borders but make them thinner → still adds noise
- Use shadows for separation → heavy on desktop, inconsistent across themes

### 3. Sidebar: Narrow, icon-forward
**Decision:** Reduce sidebar from 240px to 220px. Remove background fill (use transparent with hover states). Show icon + label with 8px gap. Active state uses subtle surface fill, not a distinct color. Remove "The Digital Atelier" subtitle; keep only "DevVault" brand.

**Why:** Notion's sidebar is barely noticeable until you need it. The current sidebar with its branding block and heavy background competes with content for attention.

### 4. Top bar: Minimal chrome
**Decision:** Remove filter tabs (All Items/Favorites/Recent). Reduce to: hamburger (compact only), page title, search bar, New button. Height stays 56px. Use transparent background with subtle bottom border.

**Why:** Filter tabs are non-functional (hardcoded `isSelected: true`) and add clutter. Notion's top bar is nearly invisible — just breadcrumbs and actions.

### 5. Dashboard: Replace bento grid with quick-access list
**Decision:** Remove GridView bento layout. Replace with a clean list of recent items and quick-action buttons. Show "Recent Notes", "Recent Credentials", and "Upcoming Tasks" as simple lists with hover rows.

**Why:** Bento grids are visually busy and don't scale well. Notion's home page is a simple document with links. A list-based approach is cleaner and more scannable.

### 6. Color palette: Near-monochrome with single accent
**Decision:** Keep existing Stitch palette but reduce color usage. Remove `Colors.orangeAccent`, `Colors.tealAccent`, `Colors.redAccent` from UI elements. Use a single accent color (current primary or a subtle green) for interactive states only.

**Why:** Notion uses almost no color except for tag highlights and links. Bright accent cards in the current dashboard break the calm aesthetic.

### 7. Dialogs: Flatter, more breathing room
**Decision:** Remove card-style dialog containers. Use flat forms with generous spacing between fields. Replace `AlertDialog` with custom modal that has no heavy shadow, just a subtle border.

**Why:** Current dialogs feel like nested cards. Notion's modals are flat overlays with clean forms.

### 8. Animations: Subtle, purposeful
**Decision:** Use `flutter_animate` for: list item fade-in (staggered 30ms), sidebar hover transition (150ms), page transition fade (200ms). No bounce, no elastic curves — use Curves.easeOut.

**Why:** Notion's animations are nearly imperceptible but make the app feel alive. Over-animated UI feels gimmicky.

## Risks / Trade-offs

- **[Risk] Removing borders may reduce clarity on low-DPI screens** → Mitigation: Keep 1px subtle borders on list containers; test at 100% and 125% DPI
- **[Risk] Narrower sidebar may feel cramped on smaller windows** → Mitigation: Already have compact mode (<1080px) that switches to drawer; keep that behavior
- **[Risk] Removing filter tabs loses potential functionality** → Mitigation: Tabs are currently non-functional; can re-add as proper filters later if needed
- **[Trade-off] Near-monochrome palette may feel "boring" to some users** → Acceptable: The goal is calm productivity, not visual excitement. Tags and status indicators can still use color
- **[Trade-off] Custom dialogs vs AlertDialog** → Slightly more code to maintain, but significantly better visual consistency

## Migration Plan

1. Update `app_theme.dart` with refined typography and color tokens
2. Create shared widget library in `lib/widgets/` (NotionListTile, NotionEmptyState, NotionDialog)
3. Refactor `dashboard_screen.dart` sidebar and top bar
4. Replace HomeOverview bento grid with list-based layout
5. Update VaultView, NotesView, TasksView list rendering
6. Refactor lock screen with cleaner form layout
7. Add micro-animations to list items and transitions
8. Manual QA across light/dark themes and window sizes

Rollback: All changes are visual only — revert git commits to restore previous UI. No data migration needed.

## Open Questions

- Should the sidebar support collapsible sections (like Notion's Favorites/Workspace)? → Defer to future iteration
- Should search be a modal overlay (Cmd+K style) instead of inline? → Consider for future; current inline search works
- What accent color for interactive states? → Use existing primary (#5F5E5E light / #E5E2E1 dark) for consistency
