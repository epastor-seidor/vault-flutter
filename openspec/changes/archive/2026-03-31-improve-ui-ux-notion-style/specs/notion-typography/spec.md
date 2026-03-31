## ADDED Requirements

### Requirement: Typography scale and weight restrictions
The application SHALL use a restricted typography scale with only three font weights: 400 (regular) for body text, 500 (medium) for labels and secondary text, and 600 (semibold) for headings. Font weights 700, 800, and 900 SHALL NOT be used anywhere in the UI.

#### Scenario: Body text rendering
- **WHEN** body text is rendered in any view
- **THEN** it uses Inter font at weight 400, 14px size, 1.5 line height

#### Scenario: Heading text rendering
- **WHEN** a page or section heading is rendered
- **THEN** it uses Inter font at weight 600 with negative letter-spacing of -0.02em

#### Scenario: No heavy font weights in UI
- **WHEN** any UI element is rendered
- **THEN** no font weight exceeds 600 (w700, w800, w900 are prohibited)

### Requirement: Title typography specifications
Page titles SHALL be 24px at weight 600. Section titles SHALL be 18px at weight 600. Subsection titles SHALL be 14px at weight 600. All titles SHALL use negative letter-spacing (-0.02em) and line height of 1.2.

#### Scenario: Page title display
- **WHEN** a page title is displayed (e.g., "Credenciales", "Notes")
- **THEN** it renders at 24px, weight 600, letter-spacing -0.02em, line-height 1.2

#### Scenario: Section title display
- **WHEN** a section title is displayed within a page
- **THEN** it renders at 18px, weight 600, letter-spacing -0.02em, line-height 1.2

### Requirement: Monospace font for sensitive data
Passwords, API keys, and other sensitive string values SHALL be displayed using a monospace font (Courier or equivalent) to aid visual verification of characters.

#### Scenario: Password display in vault list
- **WHEN** a password is shown in the credentials view
- **THEN** it uses monospace font for character clarity

#### Scenario: Copied value feedback
- **WHEN** a credential value is copied to clipboard
- **THEN** the toast/snackbar notification uses regular Inter font (not monospace)
