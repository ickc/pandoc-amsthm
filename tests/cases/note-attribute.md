---
amsthm:
  plain: [Theorem]
---

::: {.Theorem info="Fermat, little theorem (1640)"}
Plain text, as before.
:::

::: {.Theorem info="*Euler*"}
Markup, shown as typed, with a warning.
:::

::: {.Theorem info="Euler's $e$"}
More: no second warning.
:::

::: {.Theorem info="the attribute"}
[the span]{.info} Both: the span wins, with a warning.
:::

::: {.Theorem info="the attribute"}
[]{.info} An empty span: the attribute is the note, without a warning.
:::

::: {.Theorem info="spaces at its end "}
The spaces at the attribute's ends are dropped.
:::
