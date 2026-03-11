<!-- APS v1.0 — GUI Component Specification (constants + format)
     This composite asset bundles constants and the format contract for a
     framework-agnostic GUI component spec with business requirements, design
     tokens, UX behavior, accessibility, analytics, and child component
     references. Forward-references child components; never references parent. -->

<constants>
COMPONENT_SPEC_VERSION: "1.0.0"

SPACING_SCALE: "none | 2xs | xs | sm | md | lg | xl | 2xl | 3xl | 4xl"
SIZING_MODE: "fixed | fluid | hug | fill | min | max"
LAYOUT_FLOW: "block | inline | flex_row | flex_col | grid | stack_z | absolute | fixed"
ALIGN_MAIN: "start | center | end | between | around | evenly"
ALIGN_CROSS: "start | center | end | stretch | baseline"
OVERFLOW: "visible | hidden | scroll | auto"
COLOR_ROLE: "primary | secondary | tertiary | surface | background | error | warning | success | info | on_primary | on_surface | on_background | muted | accent | destructive | border | ring | transparent"
TYPOGRAPHY_STYLE: "heading_1 | heading_2 | heading_3 | body_lg | body_md | body_sm | caption | overline | code"
FONT_WEIGHT: "thin | light | normal | medium | semibold | bold | extrabold | black"
TEXT_ALIGN: "left | center | right | justify"
TEXT_OVERFLOW: "clip | ellipsis | wrap"
RADIUS_SCALE: "none | xs | sm | md | lg | xl | full"
ELEVATION_SCALE: "none | xs | sm | md | lg | xl | 2xl | inner"
OPACITY_SCALE: "0 | 5 | 10 | 20 | 30 | 40 | 50 | 60 | 70 | 80 | 90 | 95 | 100"
BORDER_STYLE: "none | solid | dashed | dotted"
TRANSITION_DURATION: "none | fast | normal | slow"
TRANSITION_EASING: "linear | ease_in | ease_out | ease_in_out | spring"
BREAKPOINT: "xs | sm | md | lg | xl | 2xl"

SPACING_EDGE: "all | x | y | top | right | bottom | left | inline | block"
SIZE_DIMENSION: "width | height"
LAYOUT_PROPERTY: "display | direction | wrap | align_main | align_cross | overflow | position"
PRIORITY: "P0_critical | P1_high | P2_medium | P3_low"
PROP_TYPES: "String | Number | Boolean | Callback | Node | Array | Object | Enum"
STATE_SCOPES: "local | lifted | global"
STATE_TYPES: "String | Number | Boolean | Array | Object"
UX_STATES: "loading | empty | error | success"
</constants>

<formats>
<format id="GUI_COMPONENT_SPEC_V1" name="GUI Component Specification" purpose="Define a framework-agnostic GUI component with business requirements, design token mapping, UX behavior, accessibility, analytics, and child component references.">
# <COMPONENT_NAME>

**Version:** <SPEC_VERSION>
**Priority:** <PRIORITY>
**Primary User:** <PRIMARY_USER>
**Last Updated:** <LAST_UPDATED>

---

## Business Requirements

### User Story
As a <USER_ROLE>, I want <USER_GOAL> so that <USER_BENEFIT>.

### Acceptance Criteria
- <ACCEPTANCE_CRITERION>
…

### Non-functional Requirements
- <NFR>
…

### Constraints
- <CONSTRAINT>
…

---

## Component Description

<COMPONENT_DESCRIPTION>

---

## Design System Mapping

- Layout Translation: <TOKEN_LAYOUT>
- Spacing Translation: <TOKEN_SPACING>
- Aesthetics Translation: <TOKEN_AESTHETICS>
- Motion Translation: <TOKEN_MOTION>

---

## Layout

| Property | Value | Responsive | Description |
| --- | --- | --- | --- |
| <LAYOUT_PROPERTY> | <LAYOUT_VALUE> | <LAYOUT_RESPONSIVE> | <LAYOUT_DESCRIPTION> |
…

## Spacing

| Edge | Padding | Margin | Gap | Description |
| --- | --- | --- | --- | --- |
| <SPACING_EDGE> | <SPACING_PADDING> | <SPACING_MARGIN> | <SPACING_GAP> | <SPACING_DESCRIPTION> |
…

## Sizing

| Dimension | Mode | Value | Min | Max | Description |
| --- | --- | --- | --- | --- | --- |
| <SIZE_DIMENSION> | <SIZE_MODE> | <SIZE_VALUE> | <SIZE_MIN> | <SIZE_MAX> | <SIZE_DESCRIPTION> |
…

## Typography

| Element | Style | Weight | Align | Overflow | Color | Description |
| --- | --- | --- | --- | --- | --- | --- |
| <TYPO_ELEMENT> | <TYPO_STYLE> | <TYPO_WEIGHT> | <TYPO_ALIGN> | <TYPO_OVERFLOW> | <TYPO_COLOR> | <TYPO_DESCRIPTION> |
…

## Colors and Surfaces

| Target | Role | Value | Opacity | Description |
| --- | --- | --- | --- | --- |
| <COLOR_TARGET> | <COLOR_ROLE> | <COLOR_VALUE> | <COLOR_OPACITY> | <COLOR_DESCRIPTION> |
…

## Borders and Shadows

| Target | Width | Style | Radius | Shadow | Description |
| --- | --- | --- | --- | --- | --- |
| <BORDER_TARGET> | <BORDER_WIDTH> | <BORDER_STYLE> | <BORDER_RADIUS> | <BORDER_SHADOW> | <BORDER_DESCRIPTION> |
…

## Transitions

| Trigger | Property | Duration | Easing | Description |
| --- | --- | --- | --- | --- |
| <TRANSITION_TRIGGER> | <TRANSITION_PROPERTY> | <TRANSITION_DURATION> | <TRANSITION_EASING> | <TRANSITION_DESCRIPTION> |
…

## Responsive Overrides

| Breakpoint | Target | Property | Value | Description |
| --- | --- | --- | --- | --- |
| <RESPONSIVE_BREAKPOINT> | <RESPONSIVE_TARGET> | <RESPONSIVE_PROPERTY> | <RESPONSIVE_VALUE> | <RESPONSIVE_DESCRIPTION> |
…

---

## Props

| Prop | Type | Required | Default | Description |
| --- | --- | --- | --- | --- |
| <PROP_NAME> | <PROP_TYPE> | <PROP_REQUIRED> | <PROP_DEFAULT> | <PROP_DESCRIPTION> |
…

## State

| State Key | Type | Scope | Initial | Description |
| --- | --- | --- | --- | --- |
| <STATE_KEY> | <STATE_TYPE> | <STATE_SCOPE> | <STATE_INITIAL> | <STATE_DESCRIPTION> |
…

## Events

| Event | When | Payload | Description |
| --- | --- | --- | --- |
| <EVENT_NAME> | <EVENT_WHEN> | <EVENT_PAYLOAD> | <EVENT_DESCRIPTION> |
…

---

## UX Behavior

### States
- **Loading:** <LOADING_BEHAVIOR>
- **Empty:** <EMPTY_BEHAVIOR>
- **Error:** <ERROR_BEHAVIOR>
- **Success:** <SUCCESS_BEHAVIOR>

---

## Accessibility

- <A11Y_NOTE>
…

---

## Analytics

| Event | Trigger | Payload | Description |
| --- | --- | --- | --- |
| <ANALYTICS_EVENT_NAME> | <ANALYTICS_TRIGGER> | <ANALYTICS_PAYLOAD> | <ANALYTICS_DESCRIPTION> |
…

---

## Child Components

| Child | Purpose |
| --- | --- |
| <CHILD_NAME> | <CHILD_PURPOSE> |
…

---

## Dependencies

- <DEPENDENCY_NAME>: <DEPENDENCY_PURPOSE>
…

WHERE:
- <A11Y_NOTE> is String; a component-specific accessibility consideration.
- <ACCEPTANCE_CRITERION> is String; a single testable condition that must hold; imperative voice.
- <ANALYTICS_DESCRIPTION> is String; one sentence; what insight this event provides.
- <ANALYTICS_EVENT_NAME> is String; snake_case tracking event name.
- <ANALYTICS_PAYLOAD> is String; shape of data sent with the tracking event.
- <ANALYTICS_TRIGGER> is String; user action or system event that fires the tracking event.
- <BORDER_RADIUS> is one of: RADIUS_SCALE.
- <BORDER_SHADOW> is one of: ELEVATION_SCALE.
- <BORDER_STYLE> is one of: BORDER_STYLE.
- <BORDER_TARGET> is String; element or edge the border applies to.
- <BORDER_WIDTH> is one of: SPACING_SCALE; or "none".
- <CHILD_NAME> is String; name of the child component; forward reference only; parent references are forbidden.
- <CHILD_PURPOSE> is String; one sentence; what the child component provides to this component.
- <COLOR_OPACITY> is one of: OPACITY_SCALE; or "100" if fully opaque.
- <COLOR_ROLE> is one of: COLOR_ROLE.
- <COLOR_TARGET> is String; element or region the color applies to.
- <COLOR_VALUE> is String; design system reference or literal value; "—" if role alone suffices.
- <COMPONENT_DESCRIPTION> is String; 1–3 sentences; what the component renders and its primary responsibility.
- <COMPONENT_NAME> is String; name of the component.
- <CONSTRAINT> is String; a business or technical limitation the component must respect.
- <DEPENDENCY_NAME> is String; package or module name.
- <DEPENDENCY_PURPOSE> is String; one sentence; why the dependency is needed.
- <EMPTY_BEHAVIOR> is String; 1–2 sentences; what the component renders when it has no data.
- <ERROR_BEHAVIOR> is String; 1–2 sentences; what the component renders on failure.
- <EVENT_DESCRIPTION> is String; one sentence; what the event signals.
- <EVENT_NAME> is String; callback name.
- <EVENT_PAYLOAD> is String; shape of data emitted with the event.
- <EVENT_WHEN> is String; user action or system condition that fires the event.
- <LAST_UPDATED> is ISO8601.
- <LAYOUT_DESCRIPTION> is String; one sentence; why this layout choice.
- <LAYOUT_PROPERTY> is one of: LAYOUT_PROPERTY.
- <LAYOUT_RESPONSIVE> is Boolean; true if value changes across breakpoints.
- <LAYOUT_VALUE> is String; semantic token from LAYOUT_FLOW, ALIGN_MAIN, ALIGN_CROSS, or OVERFLOW matching the property.
- <LOADING_BEHAVIOR> is String; 1–2 sentences; what the component renders while data is pending.
- <NFR> is String; a non-functional requirement such as performance budget, bundle size limit, or render time target.
- <PRIMARY_USER> is String; the primary persona or role that interacts with this component.
- <PRIORITY> is one of: PRIORITY.
- <PROP_DEFAULT> is String; default value or "—" if none.
- <PROP_DESCRIPTION> is String; one sentence; what the prop controls.
- <PROP_NAME> is String; property name.
- <PROP_REQUIRED> is one of: true, false.
- <PROP_TYPE> is one of: PROP_TYPES.
- <RESPONSIVE_BREAKPOINT> is one of: BREAKPOINT.
- <RESPONSIVE_DESCRIPTION> is String; one sentence; why the override.
- <RESPONSIVE_PROPERTY> is String; the property being overridden.
- <RESPONSIVE_TARGET> is String; which section or element the override applies to.
- <RESPONSIVE_VALUE> is String; the new value at this breakpoint.
- <SIZE_DESCRIPTION> is String; one sentence; sizing rationale.
- <SIZE_DIMENSION> is one of: SIZE_DIMENSION.
- <SIZE_MAX> is String; maximum constraint or "—".
- <SIZE_MIN> is String; minimum constraint or "—".
- <SIZE_MODE> is one of: SIZING_MODE.
- <SIZE_VALUE> is String; token, number with unit, or "—" if mode is hug or fill.
- <SPACING_DESCRIPTION> is String; one sentence; why this spacing.
- <SPACING_EDGE> is one of: SPACING_EDGE.
- <SPACING_GAP> is one of: SPACING_SCALE; or "—".
- <SPACING_MARGIN> is one of: SPACING_SCALE; or "—".
- <SPACING_PADDING> is one of: SPACING_SCALE; or "—".
- <SPEC_VERSION> is String; semantic version of this specification.
- <STATE_DESCRIPTION> is String; one sentence; what the state tracks.
- <STATE_INITIAL> is String; initial value expression.
- <STATE_KEY> is String; state variable name.
- <STATE_SCOPE> is one of: STATE_SCOPES.
- <STATE_TYPE> is one of: STATE_TYPES.
- <SUCCESS_BEHAVIOR> is String; 1–2 sentences; what the component renders on successful data load.
- <TOKEN_AESTHETICS> is String; summarizes how COLOR_ROLE, TYPOGRAPHY_STYLE, FONT_WEIGHT, RADIUS_SCALE, ELEVATION_SCALE, and OPACITY_SCALE map to the target framework syntax.
- <TOKEN_LAYOUT> is String; summarizes how LAYOUT_FLOW, ALIGN_MAIN, ALIGN_CROSS, and OVERFLOW map to the target framework syntax.
- <TOKEN_MOTION> is String; summarizes how TRANSITION_DURATION and TRANSITION_EASING map to the target framework syntax.
- <TOKEN_SPACING> is String; summarizes how SPACING_SCALE and SIZING_MODE map to the target framework syntax.
- <TRANSITION_DESCRIPTION> is String; one sentence; transition intent.
- <TRANSITION_DURATION> is one of: TRANSITION_DURATION.
- <TRANSITION_EASING> is one of: TRANSITION_EASING.
- <TRANSITION_PROPERTY> is String; property or semantic target being animated.
- <TRANSITION_TRIGGER> is String; interaction or state change that starts the transition.
- <TYPO_ALIGN> is one of: TEXT_ALIGN.
- <TYPO_COLOR> is one of: COLOR_ROLE.
- <TYPO_DESCRIPTION> is String; one sentence; typography intent.
- <TYPO_ELEMENT> is String; element or region the typography applies to.
- <TYPO_OVERFLOW> is one of: TEXT_OVERFLOW.
- <TYPO_STYLE> is one of: TYPOGRAPHY_STYLE.
- <TYPO_WEIGHT> is one of: FONT_WEIGHT.
- <USER_BENEFIT> is String; the value the user derives from the goal.
- <USER_GOAL> is String; the action the user wants to perform.
- <USER_ROLE> is String; the actor or persona using the component.
- … denotes repetition; one entry per item; each row or bullet follows the same pattern.
</format>
</formats>