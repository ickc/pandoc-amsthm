---
title: Styles
amsthm:
  styles:
    note:
      headfont: smallcaps
      headpunct: ":"
    exercise:
      headfont: bold
      headspace: newline
      above: 12pt
    claim:
      headfont: [bold, italic]
      bodyfont: italic
      headpunct: ""
  note:
    - Note
  exercise:
    - Exercise
  claim:
    - Claim\*
---

Besides amsthm's `plain`, `definition` and `remark`, define styles of
your own under `styles`, then list environments under each style's name.
Each style takes the settings of `\newtheoremstyle`:

- `headfont` and `bodyfont`: `bold`, `italic`, `smallcaps` or `normal`,
  or a list of them;
- `headpunct`: the punctuation after the heading;
- `headspace`: a space, `newline`, or a length such as `0.5em`;
- `above`, `below` and `indent`: lengths, for LaTeX only.

Settings left out are as for a theorem in amsthm: a bold heading, a
period and a space, and the body in the normal font.

::: {.Note info="on style"}
A heading in small caps, ending with a colon. The number stays upright,
as amsthm sets it.
:::

::: Exercise
The body starts on a new line. Prove that $\sqrt{3}$ is irrational.
:::

::: Claim
A bold italic heading with no punctuation, and an italic body.
:::
