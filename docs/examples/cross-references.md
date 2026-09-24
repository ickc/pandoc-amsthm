---
title: Cross-references
amsthm:
  plain:
    - Theorem:
        - Lemma
---

Give an environment an identifier, and cite it. A reference can come
before what it refers to, as @nz does here.

::: {#euler .Theorem info="Euler"}
$e^{i\pi} + 1 = 0$.
:::

::: {#nz .Lemma}
$e^z \neq 0$ for every complex $z$.
:::

| You write       | You get         | LaTeX gets                   |
| --------------- | --------------- | ---------------------------- |
| `@euler`        | @euler          | `\ref{euler}`                |
| `[@euler]`      | [@euler]        | `\eqref{euler}`              |
| `@Euler`        | @Euler          | `Theorem~\ref{euler}`        |
| `[@Euler]`      | [@Euler]        | `(Theorem~\ref{euler})`      |
| `[@euler; @nz]` | [@euler; @nz]   | `\eqref{euler}, \eqref{nz}`  |
| `\ref{nz}`      | \ref{nz}        | `\ref{nz}`                   |
| `\eqref{nz}`    | \eqref{nz}      | `\eqref{nz}`                 |

Capitalising the first letter of the identifier, `@Nz`, puts the
environment's name before the number: @Nz. It stays right if Lemma
later becomes Proposition. For this, use identifiers that start with a
lowercase letter.

In the italic body of a theorem, a number from `@id` or `\ref` is
italic, as in LaTeX, and one from `[@id]` or `\eqref` upright:

::: Theorem
By @Nz and [@euler], the exponential has no zeros.
:::
