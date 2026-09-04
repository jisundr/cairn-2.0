---
name: Token Metering — Dashboard (mockup)
description: A bench-scope instrument for reading Claude Code token/cost signal, not a SaaS metric grid.
colors:
  bone: "#f1ebda"
  bone-dim: "#e7ddc0"
  window: "#f8f3e5"
  block: "#e2d7b8"
  ink: "#1a2233"
  ink-soft: "#4e5871"
  ink-faint: "#90939f"
  signal: "#c1741c"
  signal-soft: "#ecdcb6"
  signal-line: "#a8631a"
  ch1: "#1a2233"
  ch2: "#5c6478"
  ch3: "#838a9b"
  ch4: "#aeb2bd"
typography:
  label:
    fontFamily: "Big Shoulders, Arial Narrow, sans-serif"
    fontSize: "10px–15px"
    fontWeight: 600
    letterSpacing: "0.05em–0.08em"
  body:
    fontFamily: "Public Sans, -apple-system, Segoe UI, sans-serif"
    fontSize: "11.5px–16px"
    fontWeight: 400
    lineHeight: 1.3
  readout:
    fontFamily: "Martian Mono, ui-monospace, SF Mono, Menlo, monospace"
    fontSize: "10px–27px"
    fontWeight: 600
    fontFeature: "tabular-nums"
rounded:
  hairline: "1px"
  xs: "2px"
  sm: "3px"
  md: "4px"
  lg: "5px"
  xl: "6px"
spacing:
  xs: "6px"
  sm: "10px"
  md: "14px"
  lg: "18px"
  xl: "22px"
components:
  meter-box:
    backgroundColor: "{colors.window}"
    textColor: "{colors.ink}"
    rounded: "{rounded.md}"
    padding: "12px 16px"
  chart-tab-active:
    backgroundColor: "{colors.signal}"
    textColor: "{colors.window}"
    rounded: "{rounded.sm}"
    padding: "6px 13px"
  session-item-selected:
    backgroundColor: "{colors.signal-soft}"
    textColor: "{colors.ink}"
    padding: "10px 12px"
  warning-banner:
    backgroundColor: "{colors.signal-soft}"
    textColor: "{colors.ink}"
    rounded: "{rounded.lg}"
    padding: "12px 16px"
  pill-active:
    backgroundColor: "{colors.signal}"
    textColor: "{colors.window}"
    rounded: "{rounded.sm}"
    padding: "5px 12px"
---

# Design System: Token Metering — Dashboard (mockup)

## Overview

**Creative North Star: "The Bench Scope"**

This is an oscilloscope panel, not a metric-tile grid. It reads the developer's Claude Code sessions the way a technician reads a signal on a bench instrument: bone-paper ground, ink-blue-black rules and text everywhere by default, and a single amber signal color reserved for the instrument's active/triggered state. The build rejected the flat card-grid dashboard default — no colorful KPI tiles, no rainbow chart palette, no drop shadows standing in for hierarchy. Depth and hierarchy come from borders, graticule (grid) backgrounds, and tabular-numeral density, not from elevation.

The confirmed anti-reference is the project's own prior mockup/app treatment (muted paper/graphite, blue accent, Archivo + Space Mono) — evidence for this redesign, not visual authority carried forward. Also rejected: the "generic AI-scaffolded dashboard" look named directly in PRODUCT.md's principles.

**Key Characteristics:**
- One warm neutral ground (bone/window/block), one ink ink-scale for text and structure, one amber signal color used exclusively for triggered/selected/warning states
- Graticule (faint grid) backgrounds behind every chart surface, echoing scope-screen bezels
- SVG polyline + perpendicular tick overlays trace actual data over the bar charts — the signature "calibrated trace" device
- Dial-style segmented tabs (Today/Daily/Monthly, Dashboard/Sessions) that fill solid amber when active, not underline-only
- Meter-boxed readouts: bordered boxes with tracked-caps label + large tabular-mono value, styled like an instrument's numeric readout window
- Engraved tracked-caps labels (uppercase, letter-spaced Big Shoulders) throughout for anything functioning as a control or field label

## Colors

A single warm-paper neutral scale carries the whole surface; amber is the only saturated color in the system and it is rationed to state, not decoration.

### Primary
- **Signal Amber** (`#c1741c`): the one accent. Used only for: active tab fill, selected session-item marker + background wash, active chart-range tab, active pill/filter, warning-banner border and text, the pulsing status lamp, checked day-marker dot on bar charts, day-detail dot for the highest-cost model. Never used for default/at-rest chrome.
- **Signal Soft** (`#ecdcb6`): amber's low-saturation wash — selected-row background, warning-banner fill, text-selection highlight. Amber's presence without amber's weight.
- **Signal Line** (`#a8631a`): amber's darker edge, used for warning-banner dashed border and the flag badge/icon stroke.

### Neutral
- **Bone** (`#f1ebda`): the page ground, with a faint 28px graticule grid printed into it via a repeating linear-gradient.
- **Bone Dim** (`#e7ddc0`): recessed surfaces — the browser-chrome bar, day-detail box, drilldown head, chat-thread background, hbar track.
- **Window** (`#f8f3e5`): the raised/active panel surface — meter boxes, panels, tab bar background, chat bubbles, empty-state card. Lighter than bone; reads as "glass" against the bone bezel.
- **Block** (`#e2d7b8`): default (unselected) bar-chart fill and the greek-line placeholder color.
- **Ink** (`#1a2233`): primary text, borders on brand mark, headline numerals. Doubles as `--ch1`, the first data-series color.
- **Ink Soft** (`#4e5871`): secondary text — meter labels, tab labels at rest, metadata rows, agent stat numerals.
- **Ink Faint** (`#90939f`): tertiary/disabled-weight text — day labels under bars, timestamps, status-updated caption, empty-mark border.
- **Paper Line** (`rgba(23,30,44,.18)`) / **Paper Line Soft** (`rgba(23,30,44,.09)`): the two hairline-border opacities used for every panel/box/divider edge and for the graticule grid lines themselves.

### Named Rules
**The One Signal Rule.** Amber appears only on a triggered, selected, active, or warning element. If nothing on a given surface is triggered, no amber is visible — the palette reads as pure bone-and-ink until something needs attention.

**The Ink-Scale Data Rule.** Multi-series data (per-agent bars, model breakdown dots) is colored from the ink-derived channel scale (`--ch1`…`--ch4`, blue-black to pale gray), never from hue. Series are distinguished by value/darkness, not by a rainbow — amber stays reserved for state.

## Typography

**Label Font:** Big Shoulders (with Arial Narrow, sans-serif fallback)
**Body Font:** Public Sans (with -apple-system, Segoe UI fallback)
**Readout Font:** Martian Mono (with ui-monospace, SF Mono, Menlo fallback)

**Character:** A condensed, engraved display face for anything acting as a control or field label; a plain humanist sans for read content (transcript text, descriptions); a monospace with tabular numerals for every number that has to be compared or trusted at a glance.

### Hierarchy
- **Label** (600–700 weight, 9px–15px, 0.04em–0.08em tracking, uppercase): panel titles, tab text, meter labels, chart-tab text, hbar group labels, session-item badges. This is Big Shoulders' only job — it never appears in body copy.
- **Body** (400–700 weight, 11.5px–16px, 1.3–1.5 line-height): headings that read as content (brand name, drilldown session title, empty-state heading), transcript/chat bubble text, descriptive prose, footer copy.
- **Readout** (400–700 weight, 8.5px–27px, tabular-nums): every number that represents cost, tokens, a count, a timestamp, or a duration — meter values, chart headline numbers, agent stats/costs, day-detail totals, heatmap hour labels, session metadata, the URL-bar chrome text. If it's a figure the developer needs to trust, it renders in Martian Mono with tabular numerals.

### Named Rules
**The Three-Face Rule.** A given string is in exactly one of the three faces by function, never mixed within one line: label face for what names a control, body face for what a person reads as prose, mono face for what represents a measured value. Mixing faces on one string is a tell that the hierarchy has broken down.

## Layout

The whole dashboard renders inside a single bordered "instrument window" (`max-width: 1180px`), itself framed by a fake browser-chrome strip (traffic-dot circles + a mono URL field) that sits on the bone-dim ground before the app content begins — a screen-within-a-bezel device, not a bare page.

Internal rhythm runs on an approximate 4px/6px-stepped scale (6, 8, 10, 12, 14, 16, 18, 22px) rather than a single fixed unit; panel gaps land at 16–18px, section margins at 22px. Rollup panels lay out in a `repeat(auto-fit, minmax(300px, 1fr))` grid that reflows from multi-column to single-column with no explicit breakpoint. The Sessions tab uses a fixed two-column grid (`1fr 2fr`: session list, drilldown) that the mobile review confirms collapses to a stacked single column below the desktop width. The page background itself carries a 28px graticule grid printed with the paper-line-soft hairline color, visible through every panel that doesn't cover it.

## Elevation & Depth

Flat by design — there is no shadow vocabulary beyond one 1px inset line under the outer window and a 2px top hairline on meter boxes. Depth and layering are conveyed entirely by the bone → bone-dim → window three-step surface stack (recessed / mid / raised) and by borders, never by blur or offset shadow. This matches the instrument-panel metaphor: a physical scope face has engraved bezels and recessed screens, not drop shadows.

### Named Rules
**The Bezel-Not-Shadow Rule.** Elevation is expressed as a surface-tone step (bone-dim recessed, window raised) plus a 1px border, never as `box-shadow` blur. The one exception — `box-shadow: 0 1px 0 var(--paper-line-soft)` on the outer window — is a single hairline, not a diffuse shadow.

## Shapes

Corners are small and consistent: 1px on the smallest chart/track elements, 2–3px on pills/tabs/badges, 4px on panels and meter boxes, 5–6px on the outer window and empty-state card. Nothing in the system uses a large or pill-shaped radius; the sharpest allowed corner is a true circle only for status dots, lamps, and the empty-state mark. Borders are hairline (1px, occasionally 1.5px) in `--paper-line`; dashed borders (1.5px) are reserved for two specific meanings — the warning banner and the empty/placeholder states (empty-state card, day-detail's absent-data note, session-item divider). Selected/checked state is never conveyed by a thicker border alone; it always pairs a border-color shift to `--signal` with a background wash.

## Components

### Meter Boxes
The dashboard's signature readout: a bordered `--window` box with a 2px top hairline, an uppercase tracked label (Big Shoulders, 11px) above a large tabular-mono value (27px, 600 weight). Used for the top-of-page token/cost totals; no hover or interactive state — read-only instrument readouts.

### Dial Tabs
Segmented, bordered tab groups (app-level Dashboard/Sessions, chart-level Today/Daily/Monthly). Unselected segments sit on `--window` with `--ink-soft` label text; the checked segment fills solid `--signal` with `--window` text — a hard on/off dial state, not an underline or color-only indicator. The app-level tab variant instead uses an inset bottom box-shadow in signal color against a signal-soft fill, distinguishing primary navigation from secondary range controls while keeping both on the same amber vocabulary.

### Graticule Bar Charts
Bars sit on a background-image grid (horizontal 27px rows + vertical column dividers in paper-line-soft) that mimics an oscilloscope's screen graticule. An absolutely-positioned SVG overlay draws a `--ink-soft` polyline through each bar's data point plus a perpendicular tick mark at every column — the "calibrated trace" signature. Default bar fill is `--block`; the checked/selected bar (via a hidden radio + `:checked +` sibling selector) switches to `--signal-soft` fill with `--signal` borders and grows a small circular signal-colored marker above it. Three density variants exist (hourly/spark: tight gaps and no cursor; daily: clickable columns; monthly: wide gaps, no cursor) — all driven by the same `.bar-chart` base class plus a modifier.

### Session List / Drilldown
- **Session item:** dashed-bottom-bordered rows in a scrollable list; selected state washes the row in `--signal-soft` and prepends a small signal-colored square marker. A `.flag-dot` (solid amber circle) marks sessions that hit a usage limit.
- **Agent-select rows** (inside drilldown): checkbox-driven rows with a small square swatch (`::before`, colored per agent via `--ch1`/`--ch3`/`--ch4`) that fills solid when checked; a mini horizontal bar shows relative token share.
- **Chat thread:** left-border-railed turns, prompt bubbles left-aligned in `--window`, response bubbles right-aligned in `--ch1-soft` — the only place a channel color tints a background directly rather than through the ink/amber system.

### Meter/Progress Bars (hbar, mini-bar)
Flat bordered tracks (`--bone-dim` background, `--paper-line` border) filled with a solid ink-scale color (`--ink-soft` default, or the per-agent channel color in drilldown mini-bars). No gradient fill, no rounded pill ends beyond the 2px track radius.

### Empty State
A dashed-border `--window` card, centered, max-width 460px: a circular dashed-border mono-glyph mark, a body-face heading, numbered onboarding steps (circular mono step-index + body text), consistent with the rest of the system's dashed-border-means-placeholder convention. No decorative illustration — the mark is a single character in Martian Mono inside a dashed circle, keeping the empty state in the same instrument vocabulary as everything else.

### Warning Banner
Dashed signal-line border, signal-soft fill, a circular dashed-look flag badge, body text with an inline mono `<code>` treatment for identifiers, and a right-aligned bold underlined link. The only banner-level surface in the system that uses amber as a fill rather than a rationed accent — justified because a usage-limit warning is itself the triggered state the whole One Signal Rule exists to signal.

## Do's and Don'ts

### Do:
- **Do** keep amber (`--signal` family) exclusively on triggered/selected/warning/active elements; every other surface stays bone/ink.
- **Do** route every number a developer needs to trust through Martian Mono with `font-variant-numeric: tabular-nums`.
- **Do** express elevation as a surface-tone step (bone-dim/window) plus a hairline border, not a blurred shadow.
- **Do** back chart surfaces with the 27px/paper-line-soft graticule grid so new chart types read as part of the same instrument.
- **Do** use dashed borders only for the two established meanings: warning states and empty/placeholder states.

### Don't:
- **Don't** introduce a second saturated accent color; the ink-scale channels (`--ch1`–`--ch4`) carry all multi-series data, amber stays singular.
- **Don't** add drop shadows, blurred glows, or card-elevation effects — depth comes from the bone/bone-dim/window stack only.
- **Don't** use a pill/fully-rounded radius anywhere except true circles (dots, lamps, the empty-state mark); the established corner range tops out at 6px.
- **Don't** set label-face type (Big Shoulders) on body prose, or body-face type on a control/field label — each face has exactly one job.
