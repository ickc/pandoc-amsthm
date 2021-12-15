---
amsthm:
  counter_depth: 2
  definition:
  - Definition
  name_to_text:
    KL: Klein's Lemma
  parent_counter: section
  plain:
  - Theorem:
    - Lemma
    - Corollary
  - With Space\*
  - Proposition: Conjecture
  - WithoutSpace
  - KL
  remark:
  - Case
header-includes: |
  ```{=latex}
  \usepackage{amsthm}
  ```
---

# Demo

::: {.Theorem info="within parenthesis"}
plain theoremstyle *here*
:::

::: {#simplestEquation .Theorem}
Label and reference:

$$E=mc^2$$
:::

From the \ref{simplestEquation}, we see that...

::: {.With_Space info="within parenthesis"}
Environment name has a space, and is unnumbered.
:::

::: {.Lemma info="within parenthesis"}
This one share counter with Theorem
:::

::: {.Definition info="within parenthesis"}
definition theoremstyle here
:::

::: {.Case info="within parenthesis"}
remark theoremstyle here
:::

::: {.proof info="Proof of the Main Theorem"}
Predefined proof theoremstyle here
:::

::: KL
Klein's Lemma from amsthm doc.
:::

# Counter test

::: Theorem
some theorem
:::

::: Theorem
some theorem
:::

## Next level

::: Theorem
some theorem
:::

::: Theorem
some theorem
:::

### Level 3

::: Theorem
some theorem
:::

::: Theorem
some theorem
:::

#### Level 4

::: Theorem
some theorem
:::

::: Theorem
some theorem
:::

##### Level 5

::: Theorem
some theorem
:::

::: Theorem
some theorem
:::

###### Level 6

::: Theorem
some theorem
:::

::: Theorem
some theorem
:::