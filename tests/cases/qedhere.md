---
amsthm:
  plain: [Theorem]
---

::: proof
It ends in a display:
$$x = 1. \qedhere$$
:::

::: proof
It ends in a list:

- one
- two \qedhere
:::

::: proof
A nested proof keeps its own.

::: proof
Inner. \qedhere
:::

Outer.
:::
