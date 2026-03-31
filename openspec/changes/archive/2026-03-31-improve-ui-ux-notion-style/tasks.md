## 1. Typography System

- [x] 1.1 Update `app_theme.dart` to restrict font weights to 400/500/600 only across all text styles
- [x] 1.2 Set title letter-spacing to -0.02em and line-height to 1.2 for headings
- [x] 1.3 Set body text to 14px, weight 400, line-height 1.5 in theme defaults
- [x] 1.4 Replace all w700/w800/w900 font weight usages in `dashboard_screen.dart` with w600
- [x] 1.5 Replace all w700/w800/w900 font weight usages in `lock_screen.dart` with w600
- [x] 1.6 Ensure monospace font is applied to password display fields in vault list

## 2. Color Palette Refinement

- [x] 2.1 Remove bright accent colors (orangeAccent, tealAccent, redAccent) from `dashboard_screen.dart` BentoCard components
- [x] 2.2 Update all stat cards and bento cards to use neutral surface colors
- [x] 2.3 Ensure interactive elements use only primary color tokens
- [x] 2.4 Keep semantic colors (green/yellow/red) only for status indicators and error states

## 3. Sidebar Redesign

- [x] 3.1 Reduce sidebar width from 240px to 220px in `dashboard_screen.dart`
- [x] 3.2 Remove sidebar background fill; make it transparent with hover states
- [x] 3.3 Update sidebar brand header: remove "The Digital Atelier" subtitle, show only "DevVault"
- [x] 3.4 Update `_SidebarItem` to use 16px icons, 13px labels, 8px gap
- [x] 3.5 Add 150ms easeOut hover transition to sidebar items
- [x] 3.6 Ensure active state uses subtle surface fill (not distinct color block)
- [x] 3.7 Remove "Add New" button from sidebar bottom; keep only Settings and Lock

## 4. Top Bar Simplification

- [x] 4.1 Remove filter tabs (All Items, Favorites, Recent) from `_buildTopAppBar`
- [x] 4.2 Simplify breadcrumb to show only current page title
- [x] 4.3 Reduce search bar visual prominence (smaller, less filled appearance)
- [x] 4.4 Ensure top bar has transparent/semi-transparent background with subtle bottom border
- [x] 4.5 Keep New Item button with current Stitch styling

## 5. Dashboard Home View

- [x] 5.1 Remove `HomeOverview` bento grid layout (GridView.count)
- [x] 5.2 Replace with list-based sections: Recent Notes, Recent Credentials, Upcoming Tasks
- [x] 5.3 Create simple list rows for recent items with hover highlight
- [x] 5.4 Remove `_BentoCard`, `_RecentListCard`, `_TipsCard` widgets
- [x] 5.5 Add empty state for dashboard when no items exist

## 6. List View Refinements

- [x] 6.1 Update `_VaultCard` row to use whitespace separation instead of borders between items
- [x] 6.2 Add hover background highlight to vault list rows
- [x] 6.3 Make trailing action icons (edit, delete, copy) dimmed by default, visible on hover
- [x] 6.4 Update NotesView list items to match whitespace + hover pattern
- [x] 6.5 Update TasksView list items to match whitespace + hover pattern
- [x] 6.6 Ensure list container has subtle 1px perimeter border

## 7. Empty State Components

- [x] 7.1 Create `NotionEmptyState` reusable widget in `lib/widgets/` with icon, title, description, CTA button
- [x] 7.2 Apply empty state to VaultView when no credentials exist
- [x] 7.3 Apply empty state to NotesView when no notes exist
- [x] 7.4 Apply empty state to TasksView when no tasks exist
- [x] 7.5 Apply empty state to search results with no matches

## 8. Dialog Redesign

- [x] 8.1 Replace `AlertDialog` in `VaultView.showAddDialog` with custom flat modal
- [x] 8.2 Update dialog form fields to have labels above inputs with 16px spacing
- [x] 8.3 Remove heavy shadow from dialogs; use subtle border instead
- [x] 8.4 Update NotesView note creation/edit dialog to match flat design
- [x] 8.5 Update TasksView task creation/edit dialog to match flat design
- [x] 8.6 Ensure dialog action buttons are right-aligned (Cancel, Save)

## 9. Lock Screen Refinement

- [x] 9.1 Simplify lock screen decorative elements (reduce or remove background blobs)
- [x] 9.2 Flatten the form card: remove heavy shadow, use subtle border
- [x] 9.3 Ensure password input uses Stitch styling with proper spacing
- [x] 9.4 Update unlock button to use current primary color with full-width rounded design
- [x] 9.5 Verify dark mode lock screen matches refined aesthetic

## 10. Micro-Animations

- [x] 10.1 Add staggered fade-in (30ms delay) to vault list items on initial load
- [x] 10.2 Add staggered fade-in to notes list items on initial load
- [x] 10.3 Add staggered fade-in to tasks list items on initial load
- [x] 10.4 Add 150ms easeOut hover transition to all sidebar items
- [x] 10.5 Add 200ms fade transition for section navigation (Credentials/Notes/Tasks/Settings)
- [x] 10.6 Add press feedback (darken) to primary buttons
- [x] 10.7 Add hover circle background to icon buttons
- [x] 10.8 Verify no bounce/elastic/spring curves are used anywhere

## 11. QA and Polish

- [x] 11.1 Test all views in light theme for visual consistency
- [x] 11.2 Test all views in dark theme for visual consistency
- [x] 11.3 Test compact mode (<1080px) with drawer sidebar
- [x] 11.4 Test at 100% and 125% DPI for border clarity
- [x] 11.5 Verify keyboard shortcuts (Ctrl+F, Ctrl+N, Ctrl+L) still work
- [x] 11.6 Run `flutter analyze` and fix any warnings
- [x] 11.7 Run `flutter test` if tests exist
