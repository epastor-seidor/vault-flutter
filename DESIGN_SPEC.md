# DevVault UI/UX Design Specification

## Design Philosophy
Minimalista, limpio, centrado en el contenido. Inspirado en Notion.

## Design Tokens

### Colors - Light Mode
| Token | Hex | Usage |
|-------|-----|-------|
| `notionBg` | `#FFFFFF` | Page background |
| `notionSidebarBg` | `#FBFBFA` | Sidebar background |
| `notionSidebarHover` | `#EFEFEF` | Sidebar item hover |
| `notionSidebarActive` | `#E8E8E8` | Sidebar item active |
| `notionSurface` | `#F7F7F5` | Cards, inputs |
| `notionTextPrimary` | `#37352F` | Primary text |
| `notionTextSecondary` | `#9B9A97` | Secondary text |
| `notionBorder` | `#E9E9E7` | Borders, dividers |
| `notionFillPrimary` | `#2F2F2F` | Primary buttons |
| `notionRed` | `#EB5757` | Error, danger |
| `notionGreen` | `#4DAB92` | Success |
| `notionBlue` | `#529CCA` | Info, links |
| `notionOrange` | `#FF9122` | Warning |

### Colors - Dark Mode
| Token | Hex | Usage |
|-------|-----|-------|
| `notionDarkBg` | `#191919` | Page background |
| `notionDarkSidebarBg` | `#202020` | Sidebar background |
| `notionDarkSidebarHover` | `#2C2C2C` | Sidebar item hover |
| `notionDarkSidebarActive` | `#333333` | Sidebar item active |
| `notionDarkSurface` | `#262626` | Cards, inputs |
| `notionDarkTextPrimary` | `#FFFFFF` | Primary text |
| `notionDarkTextSecondary` | `#9B9B9B` | Secondary text |
| `notionDarkBorder` | `#2F2F2F` | Borders |
| `notionDarkFillPrimary` | `#D4D4D4` | Primary buttons |

### Typography
| Style | Size | Weight | Usage |
|-------|------|--------|-------|
| Page Title | 30px | 700 | Page headers |
| Heading 1 | 24px | 600 | Major sections |
| Heading 2 | 20px | 600 | Subsections |
| Heading 3 | 16px | 600 | Minor headers |
| Body | 14px | 400 | Standard text |
| Body Small | 12px | 400 | Captions |
| Sidebar | 14px | 400/500 | Nav items |

### Spacing (4px grid)
4px, 8px, 12px, 16px, 20px, 24px, 32px, 48px, 64px

### Border Radius
- `sm`: 3px (buttons, inputs, list items, tags)
- `md`: 5px (cards, containers)
- `lg`: 8px (large containers, modals)

### Shadows
- **NO elevation** on cards, buttons, list items
- Only modal/dialog shadow: `0 4px 24px rgba(0,0,0,0.12)`

## Component Specs

### Sidebar (224px)
- Background: `#FBFBFA` / `#202020`
- Row height: 28px
- Icon: 16px
- Border radius: 3px
- Hover: `#EFEFEF` / `#2C2C2C`
- Active: `#E8E8E8` / `#333333`

### Top Bar (44px)
- Height: 44px
- Breadcrumb: left-aligned, slash-separated
- Single "+ New" button (dark fill)
- Search: compact, right-aligned

### Cards / List Items
- Border: 1px solid `#E9E9E7`
- Border radius: 3px
- NO shadows
- Row height: 36px
- Hover: `#FBFBFA` / `#262626`

### Buttons
- Primary: dark fill `#2F2F2F`, white text, 3px radius, 32px height
- Secondary: text-only, hover background
- Danger: red text `#EB5757`, transparent bg

### Empty States
- Icon: 48x48, 3px radius, `#F7F7F5` bg
- Title: 16px, 600 weight
- Description: 14px, secondary color
- Action button: dark fill, 3px radius

### Lock Screen
- Minimal, no decorative elements
- No shadows, no blur circles
- Icon: 40x40, 3px radius
- Button: 3px radius (not pill)
- Clean, centered layout

### Toasts
- Position: bottom-center
- Background: white with colored icon
- Border: 1px solid `#E9E9E7`
- Border radius: 5px
- NO shadows
