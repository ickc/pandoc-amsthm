---
title: Swapped numbers
amsthm:
  swapnumbers: true
  plain:
    - Theorem:
        - Lemma
  remark:
    - Remark
---

`swapnumbers: true` puts the number before the name, as amsthm's
`\swapnumbers` does.

::: {.Theorem info="Fermat"}
If $p$ is prime, then $a^p \equiv a \pmod p$.
:::

::: Lemma
$\binom{p}{k}$ is divisible by $p$ for $0 < k < p$.
:::

::: Remark
In a swapped heading the number takes the heading's font, italic here,
where after the name it would be upright.
:::
