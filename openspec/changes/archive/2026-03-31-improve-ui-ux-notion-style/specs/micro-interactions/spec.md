## ADDED Requirements

### Requirement: List item staggered fade-in
List items SHALL animate in with a staggered fade-in effect when a list is first rendered or when items are added. Each item SHALL delay its animation by 30ms from the previous item. The animation SHALL use Curves.easeOut with 200ms duration.

#### Scenario: Initial list load animation
- **WHEN** a list view (credentials, notes, tasks) is first loaded
- **THEN** each item fades in with a 30ms stagger delay from the previous item

#### Scenario: New item added animation
- **WHEN** a new item is added to a list
- **THEN** the new item fades in with a 200ms easeOut animation

### Requirement: Sidebar hover transition
Sidebar navigation items SHALL have a smooth background color transition on hover. The transition SHALL use 150ms duration with Curves.easeOut. The background SHALL transition from transparent to surface-container-low.

#### Scenario: Sidebar item hover transition
- **WHEN** the user moves the cursor over a sidebar navigation item
- **THEN** the background color transitions smoothly over 150ms

#### Scenario: Sidebar item hover exit
- **WHEN** the user moves the cursor away from a sidebar navigation item
- **THEN** the background color transitions back to transparent over 150ms

### Requirement: Page transition fade
Navigating between main sections (Credentials, Notes, Tasks, Settings) SHALL include a subtle fade transition. The outgoing content SHALL fade out and incoming content SHALL fade in over 200ms using Curves.easeOut.

#### Scenario: Section navigation transition
- **WHEN** the user clicks a different section in the sidebar
- **THEN** the content area fades to the new section over 200ms

### Requirement: Button press feedback
Interactive buttons SHALL provide visual feedback on press. Primary buttons SHALL darken slightly on press. Icon buttons SHALL show a circular background fill on hover and a slightly darker fill on press.

#### Scenario: Primary button press
- **WHEN** the user presses a primary action button (e.g., "New Item")
- **THEN** the button background darkens slightly during the press

#### Scenario: Icon button hover and press
- **WHEN** the user hovers over an icon button
- **THEN** a subtle circular background appears behind the icon

### Requirement: No bounce or elastic animations
All animations SHALL use Curves.easeOut or Curves.linear. Bounce, elastic, spring, or overshoot curves SHALL NOT be used anywhere in the application.

#### Scenario: Animation curve compliance
- **WHEN** any animation is triggered in the application
- **THEN** it uses only Curves.easeOut or Curves.linear (no bounce, spring, or elastic curves)
