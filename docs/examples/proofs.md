---
title: Proofs
amsthm:
  plain:
    - Theorem
  qed_symbol: $\blacksquare$
---

`qed_symbol` sets the end-of-proof symbol, amsthm's `\qedsymbol`, as
math. Here it is a filled square instead of the default open box.

::: {#sqrt2 .Theorem}
$\sqrt{2}$ is irrational.
:::

::: proof
Suppose $\sqrt{2} = p/q$ in lowest terms. Then $p^2 = 2q^2$, so $p$ is
even, and then so is $q$: a contradiction.
:::

When a proof ends in a display or a list, the symbol would sit on a
line of its own. Put `\qedhere` where it should go, as in LaTeX:

::: {.proof info="Another proof of @Sqrt2"}
Write $p = 2r$. Then $4r^2 = 2q^2$, so
$$q^2 = 2r^2. \qedhere$$
:::

::: proof
Two cases remain:

1.  $q$ is odd, which contradicts $q^2 = 2r^2$;
2.  $q$ is even, which contradicts lowest terms. \qedhere
:::

A proof inside a proof ends with a symbol of its own:

::: proof
We need a lemma.

::: proof
The lemma's own proof.
:::

The rest follows.
:::
