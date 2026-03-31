## ADDED Requirements

### Requirement: Whitespace-based visual separation
The application SHALL use whitespace (padding and gaps) as the primary method for visual separation between UI elements. Borders SHALL only be used on list container boundaries, not between individual items within a list.

#### Scenario: List item separation
- **WHEN** a list of items is displayed (credentials, notes, tasks)
- **THEN** individual items are separated by whitespace (8-12px gap) without borders between them

#### Scenario: Container border presence
- **WHEN** a list container is displayed
- **THEN** the container has a single subtle 1px border around its perimeter

#### Scenario: Card component separation
- **WHEN** card-like components are displayed on the dashboard
- **THEN** they are separated by 24px gaps without borders between adjacent cards

### Requirement: Sidebar dimensions and appearance
The sidebar SHALL be 220px wide on standard layouts. It SHALL have no background fill (transparent). Navigation items SHALL use hover state background fills (surface-container-low color) on mouse-over. The active navigation item SHALL have a subtle surface fill, not a distinct color block.

#### Scenario: Standard sidebar width
- **WHEN** the window width is 1080px or greater
- **THEN** the sidebar is exactly 220px wide with transparent background

#### Scenario: Compact sidebar behavior
- **WHEN** the window width is less than 1080px
- **THEN** the sidebar collapses into a drawer accessible via hamburger menu

#### Scenario: Sidebar item hover state
- **WHEN** the user hovers over a sidebar navigation item
- **THEN** the item background changes to surface-container-low color with 150ms transition

#### Scenario: Active sidebar item appearance
- **WHEN** a navigation item is selected
- **THEN** it displays a subtle surface fill background with weight 600 text

### Requirement: Top bar minimal composition
The top bar SHALL contain only: hamburger menu (compact mode only), page title/breadcrumb, search input, and New Item button. Filter tabs (All Items, Favorites, Recent) SHALL NOT be displayed.

#### Scenario: Top bar in standard mode
- **WHEN** the window width is 1080px or greater
- **THEN** the top bar shows page title, search input, and New Item button (no hamburger)

#### Scenario: Top bar in compact mode
- **WHEN** the window width is less than 1080px
- **THEN** the top bar shows hamburger menu, page title, search input, and New Item button

#### Scenario: No filter tabs visible
- **WHEN** the top bar is rendered in any mode
- **THEN** no filter tabs (All Items, Favorites, Recent) are displayed

### Requirement: Dashboard list-based layout
The dashboard/home view SHALL display content as a list of recent items and quick-action sections instead of a bento grid. It SHALL show: recent notes, recent credentials, and upcoming tasks as simple list sections.

#### Scenario: Dashboard renders as list
- **WHEN** the user navigates to the home/overview page
- **THEN** they see list-based sections (Recent Notes, Recent Credentials, Upcoming Tasks) instead of a grid

#### Scenario: Empty dashboard state
- **WHEN** there are no items in any category on the dashboard
- **THEN** each section shows an empty state message with a call-to-action button

### Requirement: Near-monochrome color usage
The application SHALL use near-monochrome colors for all structural UI elements. Bright accent colors (orange, teal, red, etc.) SHALL NOT be used for cards, buttons, or decorative elements. Color SHALL only be used for: status indicators (success=green, warning=yellow, error=red), tag highlights, and link text.

#### Scenario: Dashboard cards use neutral colors
- **WHEN** dashboard section cards are rendered
- **THEN** they use neutral surface colors, not bright accent colors

#### Scenario: Interactive elements use primary color
- **WHEN** buttons and interactive elements are rendered
- **THEN** they use the primary color token (not bright accents)

#### Scenario: Status indicators retain color
- **WHEN** a status indicator is displayed (e.g., security score, error state)
- **THEN** appropriate semantic colors (green/yellow/red) are used

### Requirement: Dialog flat design
Dialogs and modals SHALL use a flat design with no heavy shadows. They SHALL have a subtle border, generous internal spacing (16px between form fields), and no nested card containers within the dialog body.

#### Scenario: Add credential dialog appearance
- **WHEN** the user opens the "Add Credential" dialog
- **THEN** it displays as a flat overlay with subtle border and 16px spacing between form fields

#### Scenario: Dialog form field spacing
- **WHEN** a dialog contains multiple form fields
- **THEN** each field has 16px vertical spacing from adjacent fields
