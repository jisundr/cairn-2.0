---
name: Token Metering — Dashboard
description: A clean, minimal SaaS instrument for reading Claude Code token/cost signal, in the register of Linear/Vercel dashboards.
colors:
  page-bg: "#fafafa"
  surface: "#ffffff"
  surface-muted: "#f4f4f5"
  border: "#e4e4e7"
  border-soft: "#eeeef0"
  ink: "#18181b"
  ink-soft: "#52525b"
  ink-faint: "#a1a1aa"
  accent: "#4f46e5"
  accent-soft: "#eef2ff"
  accent-line: "#6366f1"
  warn: "#b45309"
  warn-soft: "#fef3c7"
  ch1: "#4f46e5"
  ch1-soft: "#eef2ff"
  ch2: "#0ea5e9"
  ch3: "#10b981"
  ch4: "#f59e0b"
typography:
  headline:
    fontFamily: "Public Sans, -apple-system, Segoe UI, sans-serif"
    fontSize: "19px"
    fontWeight: 700
    letterSpacing: "-0.01em"
  body:
    fontFamily: "Public Sans, -apple-system, Segoe UI, sans-serif"
    fontSize: "11.5px–13.5px"
    fontWeight: 400
    lineHeight: 1.3
  label:
    fontFamily: "Public Sans, -apple-system, Segoe UI, sans-serif"
    fontSize: "9px–13px"
    fontWeight: 500–600
    letterSpacing: "0.02em–0.05em"
  mono:
    fontFamily: "Martian Mono, ui-monospace, SF Mono, Menlo, monospace"
    fontSize: "10px–27px"
    fontWeight: 400–700
    fontFeature: "tabular-nums"
rounded:
  xs: "2px"
  sm: "3px"
  md: "6px"
  lg: "8px"
  xl: "12px"
  full: "9999px"
spacing:
  xs: "6px"
  sm: "10px"
  md: "14px"
  lg: "16px"
  xl: "18px"
  2xl: "22px"
components:
  panel:
    backgroundColor: "{colors.surface}"
    textColor: "{colors.ink}"
    rounded: "{rounded.lg}"
    padding: "16px 16px 18px"
  meter-box:
    backgroundColor: "{colors.surface}"
    textColor: "{colors.ink}"
    rounded: "{rounded.lg}"
    padding: "14px 16px"
  tab-segment-active:
    backgroundColor: "{colors.surface}"
    textColor: "{colors.accent}"
    rounded: "{rounded.xs}"
    padding: "4px 10px"
  button-pill:
    backgroundColor: "{colors.surface}"
    textColor: "{colors.ink-soft}"
    rounded: "{rounded.md}"
    padding: "6px 10px"
  badge-count:
    backgroundColor: "transparent"
    textColor: "{colors.ink-soft}"
    rounded: "{rounded.full}"
    width: "17px"
    height: "17px"
  warning-banner:
    backgroundColor: "{colors.warn-soft}"
    textColor: "{colors.ink}"
    rounded: "{rounded.lg}"
    padding: "12px 16px"
---

# Design System: Token Metering — Dashboard

## Overview

**Creative North Star: "Clean Minimal SaaS"**

This is a plain, confident numbers tool, not an instrument panel. The build deliberately rejected two things: the retro bezel-and-graticule "Bench Scope" world that preceded it (bone-paper ground, amber signal, engraved condensed labels, oscilloscope trace overlays), and the decorated, gradient-and-shadow "generic AI-scaffolded dashboard" default. What's left is a near-white page, white flat cards distinguished only by a 1px border, a single restrained indigo accent reserved for active/selected state, and one humanist sans doing double duty as both body copy and uppercase micro-labels — there is no separate condensed display face. Numbers a developer needs to trust render in tabular monospace; everything else renders in the same body sans whether it's naming a control or describing content.

Depth and hierarchy come from a two-step surface stack (page background vs. white card) plus hairline borders — never from elevation. As of this build, there is no `box-shadow` anywhere in the system: the last four stray `shadow-sm` instances (tabs, header, chart tooltip, heatmap tooltip) were removed so the "no drop shadows" posture is actually true everywhere, not just mostly true.

**Key Characteristics:**
- One near-white ground (`--page-bg`) with white cards (`--surface`) distinguished only by a 1px border, never by shadow
- One accent (indigo) used exclusively for active/selected state, small emphasis, and focus — everything else stays gray/ink
- No bordered outer "window" wrapper around the page; content is a centered `max-w-[1180px]` column directly on the page background
- Segmented pill tabs whose active state is a background+text-color swap (white pill, indigo text), not a solid color fill
- Every number a developer needs to trust — cost, tokens, counts, durations, percentages — renders in Martian Mono with tabular numerals; everything else renders in Public Sans
- A disclosed, deliberate second color (amber `--warn`) exists solely for the usage-limit warning banner — semantic alerting only, never decoration
- Loading states use a dedicated `Skeleton` primitive sized to the content it's replacing, not a flash of zero values
- All icons are `lucide-react` line icons; no Unicode-glyph or emoji icons anywhere

## Colors

A two-step neutral scale (near-white page, white card) carries the whole surface; indigo is the one saturated accent and it is rationed to active/selected/focus state, not decoration.

### Primary
- **Accent Indigo** (`#4f46e5`): the one accent. Used for: active tab-segment text, the pulsing status lamp, selected/hovered day-bar fill+stroke on the 7-day chart, the sparkline bar fill (via `--accent-line`), the focus-visible outline (via `--accent-line`), the `::selection` highlight background (via `--accent-soft`). Never used for default/at-rest chrome.
- **Accent Soft** (`#eef2ff`): indigo's low-saturation wash — text selection highlight, the ping-animation ring around the status lamp. Also reused as `--ch1-soft` for the chat-thread response bubble fill, the one place a channel color tints a background directly.
- **Accent Line** (`#6366f1`): indigo's slightly brighter edge — the sparkline bar fill and the global `:focus-visible` outline color.

### Neutral
- **Page Background** (`#fafafa`): the page ground. Flat; no grid, no texture.
- **Surface** (`#ffffff`): every card, panel, meter box, tooltip, tab-bar active segment, and the header's "auto-refresh 15s" chip. Reads as "the content layer" against the page ground.
- **Surface Muted** (`#f4f4f5`): recessed/secondary fills — the tab-bar track behind the active segment, the day-detail box, the default (unselected) bar-chart fill, the chart-hover cursor fill, skeleton placeholders, empty heatmap cells.
- **Ink** (`#18181b`): primary text, headline numerals, active chart-tooltip label text.
- **Ink Soft** (`#52525b`): secondary text — meter labels, tab labels at rest, panel titles, metadata rows, agent stat numerals.
- **Ink Faint** (`#a1a1aa`): tertiary text — chart axis tick labels, timestamps, disabled-weight captions, agent-row percentage labels.
- **Border** (`#e4e4e7`) / **Border Soft** (`#eeeef0`): the two hairline-border weights used for every card/panel/divider edge and chart gridline. Border-soft is reserved for lighter internal dividers (e.g. between stacked agent rows).

### Secondary (disclosed exception)
- **Warn** (`#b45309`) / **Warn Soft** (`#fef3c7`): amber, confined to the usage-limit warning banner only — its border/icon/link text and its fill. This is the one place a second hue is allowed in the system.

### Named Rules
**The One Accent Rule.** Indigo (`--accent` family) appears only on active, selected, or focused elements. Multi-series data does not draw from it, decoration does not draw from it; if nothing on a surface is active or selected, no indigo is visible.

**The Disclosed-Exception Rule.** A second saturated hue is permitted exactly once in the system: `--warn`/`--warn-soft` on the usage-limit warning banner. It exists because a usage-limit hit is itself the alerting condition the One Accent Rule is designed to protect — semantic alerting only, never decoration, and never extended to a second component.

**The Channel-Hue Rule.** Multi-series data (per-agent bars/swatches in the session drilldown, per-model dots in the day-detail breakdown) cycles a four-color hue set (`--ch1` indigo, `--ch2` sky, `--ch3` emerald, `--ch4` amber), distinguishing series by hue. The Activity Heatmap is the one exception: it stays single-hue, stepping `--accent` through 15%/45%/100% opacity rather than drawing from the channel set, because it's showing intensity of one signal (call volume) over time, not distinct series.

## Typography

**Body Font:** Public Sans (400/600/700, with -apple-system, Segoe UI fallback)
**Readout Font:** Martian Mono (400/600/700, with ui-monospace, SF Mono, Menlo fallback)

**Character:** One humanist sans carries everything that isn't a measured value — headings, body copy, and uppercase tracked micro-labels alike; there is no separate condensed display/label face. A tabular monospace carries every number a developer needs to trust or compare at a glance.

### Hierarchy
- **Headline** (700 weight, 19px, tight tracking): the app wordmark ("Token Metering") — the only large display text in the system.
- **Body** (400–600 weight, 11.5px–13.5px, 1.3 line-height): panel copy, agent/session names, chat-thread prompt/response text, empty-state heading and step text.
- **Label** (500–600 weight, 9px–13px, 0.02em–0.05em tracking, uppercase where used as a section marker): panel titles, meter-box labels, tab text, chat-turn role markers ("prompt"/"response"), the "full transcript" chat-thread caption. Rendered in the same Public Sans face as body copy — case and tracking carry the distinction, not a different font.
- **Mono** (400–700 weight, 10px–27px, tabular-nums): every number that represents cost, tokens, a count, a percentage, a duration, or a timestamp — meter-box values, chart headline totals, agent/model stats, day-detail totals, session runtime, call metadata lines, heatmap tooltip counts.

### Named Rules
**The Two-Face Rule.** A string is in exactly one of two faces by function: Public Sans for anything read as a label or as prose, Martian Mono for anything that represents a measured value. There is no third "display" face reserved for headings — the 19px wordmark is simply the largest instance of the same body face.

## Layout

The page has no bordered outer wrapper: content sits directly on `--page-bg` inside a centered column capped at `max-width: 1180px` (`px-6 py-8`). This is a deliberate rejection of the prior system's bordered "instrument window."

The header is a slim row (wordmark + mark, app-level segmented tab bar, auto-refresh chip + refresh button + last-updated caption) separated from content by a single bottom border. Below it: a flat row of stat cards (`flex-wrap`, `gap-3`, each card `flex-1 basis-[170px]`), then a two-column panel grid (`grid-cols-1 lg:grid-cols-[1.3fr_1fr]`, `gap-4.5`) that collapses to one column below the desktop breakpoint. The Sessions tab instead stacks a sessions table above the selected session's drilldown panel.

Internal rhythm runs on Tailwind's spacing scale including half-steps (`px-6`, `gap-3`, `gap-4.5`, `p-4`, `pb-4.5`, `mb-3.5`, `py-3.5`) — roughly a 4px-stepped scale with 2px half-steps rather than a single fixed unit. Panel internal padding lands at 16px with an extra 2px at the bottom; section gaps land at 16–18px.

Tab state for the two top-level views (Dashboard/Sessions) lives in the URL path via `pushState`/`popstate` rather than a router library, so a hard reload of `/sessions` lands back on the Sessions tab.

## Elevation & Depth

Flat. There is no shadow vocabulary in this system — `box-shadow` does not appear anywhere in the shipped CSS or components; the four stray `shadow-sm` instances that existed mid-build (tabs, header chip, chart tooltip, heatmap tooltip) were removed so this is now true without exception. Depth is conveyed entirely by the `--page-bg` → `--surface` two-step tone stack plus a 1px `--border`, and by the `--surface-muted` third tone for recessed/secondary fills (tab-bar track, day-detail box, unselected chart bars, skeletons).

### Named Rules
**The No-Shadow Rule.** Elevation is expressed as a surface-tone step (page vs. surface vs. surface-muted) plus a 1px border, never as `box-shadow`. This is a hard invariant as of this build, not an aspiration — verify by grepping for `shadow` across `frontend/src`.

## Shapes

Corners run small: 2px on skeletons and small chart marks, 2–3px on the active tab-segment and heatmap cells, 6px on tabs/buttons/tooltips/day-detail boxes, 8px on panels/meter boxes/cards, 12px on the empty-state card. A true circle is reserved for status indicators (the pulsing lamp, the count badge, the empty-state icon ring, numbered onboarding-step markers). Borders are a single hairline weight (1px `--border`, or `--border-soft` for lighter internal dividers) throughout — no dashed borders and no border-weight changes to indicate state; selected/checked state is conveyed by a background-tone or text-color shift, not by a thicker or dashed border.

## Components

### Buttons
- **Shape:** rounded-md (6px)
- **Primary/"pill":** `--surface` background, `--border` 1px border, `--ink-soft` text (12.5px medium); hover shifts background to `--surface-muted` and text to `--ink`. Used for the header's "Refresh now" action.
- **Ghost:** transparent background and border; same hover treatment. Reserved for lower-emphasis actions.

### Tabs
- **Style:** segmented pill group — a `--surface-muted` track (rounded-md, 2px padding) containing individually-clickable label buttons (rounded 5px). The active segment swaps to `--surface` background with `--accent` text; inactive segments stay `--ink-soft` text with no fill.
- **Used for:** the app-level Dashboard/Sessions switch and the chart-level range tabs (Today/7D/30D/Month/6M/Life) — same idiom at both levels so the whole app reads as one tab convention.
- **This is a deliberate reversal of the outgoing system's "dial tab":** the active state is a text-color + light background swap, never a solid color fill.

### Cards / Panels
- **Corner Style:** 8px radius (`rounded-lg`)
- **Background:** `--surface` (white) only
- **Shadow Strategy:** none — see Elevation & Depth
- **Border:** 1px `--border`
- **Internal Padding:** 16px, 18px at the bottom (`p-4 pb-4.5`)
- **Title:** uppercase, tracked, 11px semibold `--ink-soft` label row (`PanelTitle`), with an optional inline icon slot

### Meter / Stat Cards
The dashboard's headline readout: a `--surface` card (same shape as a Panel) holding an 11px medium `--ink-soft` label above a 27px semibold Martian Mono value in `--ink`, tabular-nums. Flex-wraps in a row at the top of the dashboard tab. Loading state swaps the value for a `Skeleton` sized to match (`h-[27px] w-16`) rather than showing a zero.

### Chips / Badges
- **Count badge:** a 17×17px circle, `--ink-soft` 1px border, mono bold text — used for the warning banner's event count.
- **Inline code chip:** `--surface` background pill (`rounded px-1 py-0.5`), Martian Mono text — used for session IDs and file-path references inside prose.

### Tooltips
- **Chart tooltip:** a real recharts `<Tooltip>` (`ChartTooltip`), rendered as a `--surface` card (rounded-md, 1px `--border`) with an `--ink` label line and `--ink-soft` tabular value lines below it — hover-tracked by recharts, not a custom hit-test.
- **Heatmap tooltip:** a CSS `group-hover` tooltip (no JS state), same `--surface`/`--border`/rounded-md treatment, revealed above the hovered cell.

### Skeleton (loading state)
A `bg-(--surface-muted)` block with `animate-pulse`, sized to match the content slot it's replacing (stat-card value, hbar-list rows, chart area). Introduced this build to replace a flash of zero-value defaults on initial fetch; wired into stat cards, `HbarList`, and `TokensPerDayPanel`'s chart region.

### Bar Charts (Tokens / Day panel)
Real recharts `BarChart`s in three density variants driven by the selected range: hourly (today), daily-click (7D, clickable per-day columns with a `CartesianGrid` and axis), and sparkline (30D/Month/6M/Life, no grid or axis). Default bar fill is `--surface-muted` with a `--border` stroke; the selected/hovered day bar (7D view) switches to `--accent` fill and stroke. The sparkline variant fills bars with `--accent-line`. Clicking a day bar (7D only) opens an inline day-detail breakdown by model, each row marked with a small dot cycling the `--ch1`–`--ch4` channel colors.

### Activity Heatmap
A 7×24 grid of `aspect-square` cells (2px radius). Cell intensity is a single-hue opacity ramp of `--accent` — empty (bordered `--surface-muted`), 15%, 45%, or 100% opacity — not a separate multi-hue scale and not drawn from the `--ch1`–`--ch4` channel set. A CSS `group-hover` tooltip on each cell shows call count and token total.

### Session Drilldown (signature component)
- **Agent-select rows:** a `label`-wrapped row with a visually-hidden checkbox (`sr-only`, focus-visible extended onto the label via `label:has(input:focus-visible)`), a small square swatch (2.25×2.5px, rounded 2px) that fills solid in the row's `--ch1`–`--ch4` channel color when checked, an inline mini progress bar (bordered `--surface-muted` track, channel-colored fill) with a right-aligned tabular percentage label, and call/token/cost stats in mono.
- **Chat thread:** turn-grouped bubbles below the agent rows. Prompt bubbles are left-aligned, `--surface` background, 1px `--border`. Response bubbles are right-aligned and filled with `--ch1-soft` — the one place in the system a channel color tints a background directly rather than through the accent/warn system. Checking an agent row dims (opacity 0.32, not removes) every other agent's turns.

### Warning Banner
`--warn` 1px border, `--warn-soft` fill, rounded-lg. A circular `--warn`-bordered icon badge holds a `lucide-react` `AlertTriangle`; body text carries an inline mono `<code>` chip for the session ID; a count `Badge`; a right-aligned `--warn`-colored underlined link. The only surface in the system that uses a non-accent saturated color as a fill — justified because a usage-limit hit is the alerting condition itself.

### Empty State
A centered `--surface` card (rounded-xl, 12px, 1px `--border`, max-width 460px) holding a circular `--border`-ringed icon badge with a `lucide-react` `Inbox` glyph, a body-weight heading, three numbered onboarding steps (circular mono step-index badges + body text), and a footer caption below a top border. No decorative illustration.

### Icon System
All icons are `lucide-react` line icons (`AlertTriangle`, `Inbox` observed), inlined as React components at a small size (12–20px) with a defined `strokeWidth`. This replaced Unicode-glyph icons (`!`, `∅`) earlier in this build and is now the standing convention — no glyph or emoji icons anywhere in the system.

### Focus & Selection
Global `:focus-visible` shows a 2px `--accent-line` outline (2px offset, 2px corner radius). `::selection` uses `--accent-soft` background over `--ink` text. A `label:has(input:focus-visible)` rule reproduces the same outline (inset, -1px offset) on the agent-select rows' `label` wrapper, since the underlying checkbox is visually hidden.

## Do's and Don'ts

### Do:
- **Do** keep `--accent`/`--accent-line`/`--accent-soft` exclusively on active/selected/focused elements; everything else stays on the ink/gray scale.
- **Do** route every number a developer needs to trust through Martian Mono with `tabular-nums`.
- **Do** express elevation as a surface-tone step (`--page-bg`/`--surface`/`--surface-muted`) plus a 1px border, never a `box-shadow`.
- **Do** cycle `--ch1`–`--ch4` for multi-series data (per-agent, per-model), and keep the Activity Heatmap on its own single-hue `--accent` opacity ramp instead.
- **Do** use `lucide-react` for every icon; size and stroke-width consistently per context.
- **Do** size `Skeleton` placeholders to match the content slot they replace.

### Don't:
- **Don't** introduce a second saturated accent beyond the one disclosed exception (`--warn`/`--warn-soft`, confined to the usage-limit banner); no other component may adopt it.
- **Don't** add `box-shadow`, blur, or card-elevation effects anywhere — this build removed the last four instances specifically to make the rule true without exception.
- **Don't** set a solid color fill on an active tab segment — the active state is a background+text-color swap (`--surface` bg, `--accent` text), not a filled pill.
- **Don't** introduce a second display/label typeface — Public Sans carries body copy and uppercase tracked labels alike; Martian Mono is reserved for measured values only.
- **Don't** use Unicode-glyph or emoji icons; `lucide-react` is the only icon source.
- **Don't** wrap the page content in a bordered outer "window" — content sits directly on `--page-bg`.
