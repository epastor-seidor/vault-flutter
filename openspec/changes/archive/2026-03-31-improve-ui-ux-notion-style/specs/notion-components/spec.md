## ADDED Requirements

### Requirement: Notion-style list tile component
The application SHALL provide a reusable list tile component that displays items with: optional leading icon/avatar, primary text (weight 500), secondary text (weight 400, variant color), and optional trailing actions. The tile SHALL highlight on hover with a surface-container-low background.

#### Scenario: List tile hover behavior
- **WHEN** the user hovers over a list tile
- **THEN** the tile background changes to surface-container-low with a 150ms transition

#### Scenario: List tile with trailing actions
- **WHEN** a list tile has trailing actions (edit, delete, copy)
- **THEN** the action icons are visible on hover and hidden (or dimmed) when not hovering

#### Scenario: List tile selected state
- **WHEN** a list tile represents the currently selected item
- **THEN** it displays a persistent subtle background fill without requiring hover

### Requirement: Empty state component
The application SHALL provide a reusable empty state component that displays: an icon, a title message, a description, and an optional call-to-action button. Empty states SHALL appear when lists have zero items or search returns no results.

#### Scenario: Empty credentials list
- **WHEN** the vault has no saved credentials
- **THEN** an empty state is shown with a lock icon, "No credentials yet" message, and "Add your first credential" button

#### Scenario: Empty search results
- **WHEN** a search query returns no matching items
- **THEN** an empty state is shown with a search icon, "No results found" message, and the current query displayed

#### Scenario: Empty notes list
- **WHEN** the user has no notes
- **THEN** an empty state is shown with a file-text icon, "No notes yet" message, and "Create a note" button

### Requirement: Sidebar navigation component
The sidebar SHALL display: a brand header (icon + "DevVault" name), navigation items (Credentials, Notes, Tasks), a divider, and bottom actions (Settings, Lock). Each navigation item SHALL show an icon (16px) and label (13px) with 8px gap.

#### Scenario: Sidebar brand header
- **WHEN** the sidebar is rendered
- **THEN** it shows a small icon badge and "DevVault" text without the "Digital Atelier" subtitle

#### Scenario: Sidebar navigation items
- **WHEN** the sidebar navigation is displayed
- **THEN** it shows Credentials (key icon), Notes (file-text icon), and Tasks (check-circle icon) with 13px label text

#### Scenario: Sidebar bottom actions
- **WHEN** the sidebar bottom section is rendered
- **THEN** it shows Settings (settings2 icon) and Lock (lock icon) separated from navigation by a divider

### Requirement: Simplified dialog component
Dialogs SHALL use a simplified structure with: a title row (icon + title text), form fields with labels above inputs, and action buttons (Cancel, Save) aligned to the right. The dialog SHALL NOT use AlertDialog's default styling; it SHALL use a custom modal with flat design.

#### Scenario: Add/edit credential dialog
- **WHEN** the user creates or edits a credential
- **THEN** a dialog appears with fields for Site/Service, Username, Password, and URL with labels above each field

#### Scenario: Dialog cancel action
- **WHEN** the user clicks Cancel in any dialog
- **THEN** the dialog closes without saving changes

### Requirement: Password visibility toggle
Password fields SHALL include a visibility toggle icon (eye/eye-off) that switches between obscured (bullets) and plain text display. The toggle SHALL be positioned as a suffix icon within the input field.

#### Scenario: Toggle password visibility on
- **WHEN** the user clicks the eye icon on a password field
- **THEN** the password text becomes visible and the icon changes to eye-off

#### Scenario: Toggle password visibility off
- **WHEN** the user clicks the eye-off icon on a visible password field
- **THEN** the password text becomes obscured and the icon changes to eye

### Requirement: Copy-to-clipboard action
Credential values (passwords, usernames) SHALL have a copy button that copies the value to the system clipboard and shows a brief confirmation toast. The copy button SHALL use a copy icon (16px).

#### Scenario: Copy password to clipboard
- **WHEN** the user clicks the copy icon next to a password
- **THEN** the password is copied to clipboard and a "Copied" toast appears

#### Scenario: Copy username to clipboard
- **WHEN** the user clicks the copy icon next to a username
- **THEN** the username is copied to clipboard and a "Copied" toast appears
