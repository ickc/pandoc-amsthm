---
title: Numbering
amsthm:
  plain:
    - Theorem:
        - Lemma
    - Conjecture
  remark:
    - Remark
  parent_counter:
    Theorem: section
    Remark: subsection
---

`parent_counter` numbers an environment within a section, as the
optional last argument of `\newtheorem` does. Give one unit for every
environment, `parent_counter: section`, or one for each, as here.
Theorem (and Lemma, which shares its counter) is numbered within the
section, Remark within the subsection, and Conjecture, which is not
listed, through the whole document.

Number the sections, with `-N` or Quarto's `number-sections: true`;
without it, LaTeX numbers theorems 0.1, 0.2, and so does the filter.

# Groups

::: Theorem
A subgroup of a cyclic group is cyclic.
:::

::: Lemma
Every group of order 4 is abelian.
:::

::: Conjecture
Every conjecture here is numbered through the document.
:::

## Subgroups

::: Remark
Numbered within this subsection.
:::

::: Remark
And again.
:::

# Rings

::: Theorem
The numbering restarts in a new section.
:::

::: Conjecture
Still counting on.
:::

::: Remark
There is no subsection here yet, so the subsection part of its number
is 0, as in LaTeX.
:::
