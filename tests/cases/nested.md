---
amsthm:
  plain: [Theorem]
  definition: [Definition]
---

::: {#thm-outer .Theorem}
Outer statement.

::: {#thm-inner .Theorem}
Inner statement.
:::

::: Definition
A definition inside a theorem.
:::
:::

::: proof
The proof uses a lemma.

::: {#thm-in-proof .Theorem}
A theorem inside a proof.
:::
:::

See [@thm-inner] and [@thm-in-proof].
