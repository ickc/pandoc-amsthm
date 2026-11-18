---
amsthm:
  plain: [Theorem]
---

::: {#lagrange .Theorem}
[Lagrange]{.info} The order of a subgroup divides the order of the
group.
:::

::: Theorem
[A note on a line of its own]{.info}
The body.
:::

::: Theorem
[A note before a list]{.info}

- one
- two
:::

::: Theorem
[A note before a display, with $x$ and @lagrange]{.info}

$$x = 1$$
:::

::: Theorem
[Other attributes]{#n .info .foo lang=de} are ignored.
:::

::: Theorem
A [later span]{.info} is an ordinary span.
:::

::: Theorem
[]{.info} An empty note is no note.
:::

::: proof
[Proof of @Lagrange]{.info} Obvious.
:::

::: Theorem
[Outer]{.info} Outer.

::: Theorem
[Inner]{.info} Inner.
:::
:::

::: Theorem
[ ]{.info} A blank note is no note.
:::
