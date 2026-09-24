---
amsthm:
  styles:
    note:
      headfont: [smallcaps]
      bodyfont: italic
      headpunct: ":"
      headspace: newline
      above: 6pt
    claim:
      headfont: [bold, italic]
      headpunct: ""
    aside:
      headfont: normal
      bodyfont: italic
  note: [Observation]
  claim: [Claim\*]
  aside: [Aside\*]
  plain: [Theorem]
---

::: {#o .Observation info="with a note"}
The body in italics, citing @o and [@o].
:::

::: Claim
The body upright.
:::

::: Aside
The heading upright, in LaTeX too.
:::
