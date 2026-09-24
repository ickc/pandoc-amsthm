# Demo

::: {.Theorem .amsthm .amsthm-plain info="within parenthesis"}
[**Theorem 1.0.1** (within parenthesis)**.**]{.amsthm-title} *plain
theoremstyle* here

*We can use pandoc-crossref style* [1.0.2](#simplestEquation) *and*
([1.0.2](#simplestEquation)) *and cite before definition.*
:::

::: {#simplestEquation .Theorem .amsthm .amsthm-plain}
[**Theorem 1.0.2.**]{.amsthm-title} *Label and reference:*

$$E=mc^2$$
:::

From the [1.0.2](#simplestEquation), we see that... Or
([1.0.2](#simplestEquation)), ...

::: {.With_Space .amsthm .amsthm-plain info="**This** is *markdown*."}
[**With Space** (**This** is *markdown*.)**.**]{.amsthm-title}
*Environment name has a space, and is unnumbered.*
:::

::: {.Lemma .amsthm .amsthm-plain info="can cite \\ref{simplestEquation}"}
[**Lemma 1.0.3** (can cite
[1.0.2](#simplestEquation))**.**]{.amsthm-title} *This one share counter
with Theorem.*
:::

::: {.Definition .amsthm .amsthm-definition info="pandoc-crossref style cite @simplestEquation"}
[**Definition 1.0.1** (pandoc-crossref style cite
[1.0.2](#simplestEquation))**.**]{.amsthm-title} definition theoremstyle
here
:::

::: {.Case .amsthm .amsthm-remark info="within parenthesis"}
[*Case* 1.0.1 (within parenthesis)*.*]{.amsthm-title} remark
theoremstyle here
:::

::: {.proof .amsthm .amsthm-proof info="Proof of the Main Theorem"}
[*Proof of the Main Theorem**.*]{.amsthm-title} Predefined proof
theoremstyle here[◻]{.amsthm-qed}
:::

::: {.proof .amsthm .amsthm-proof info="Proof of the *little* theorem"}
[*Proof of the* little *theorem**.*]{.amsthm-title} Predefined proof
theoremstyle here with markdown info.[◻]{.amsthm-qed}
:::

::: {.proof .amsthm .amsthm-proof}
[*Proof.*]{.amsthm-title} Bare proof here.[◻]{.amsthm-qed}
:::

::: {.KL .amsthm .amsthm-plain}
[**Klein's Lemma 1.0.1.**]{.amsthm-title} *Klein's Lemma from amsthm
doc.*
:::

::: {.Definition .amsthm .amsthm-definition}
[**Definition 1.0.2.**]{.amsthm-title}

    code here
:::

# Counter test

::: {.Theorem .amsthm .amsthm-plain}
[**Theorem 2.0.1.**]{.amsthm-title} *some theorem*
:::

::: {.Theorem .amsthm .amsthm-plain}
[**Theorem 2.0.2.**]{.amsthm-title} *some theorem*
:::

## Next level

::: {.Theorem .amsthm .amsthm-plain}
[**Theorem 2.1.1.**]{.amsthm-title} *some theorem*
:::

::: {.Theorem .amsthm .amsthm-plain}
[**Theorem 2.1.2.**]{.amsthm-title} *some theorem*
:::

### Level 3

::: {.Theorem .amsthm .amsthm-plain}
[**Theorem 2.1.3.**]{.amsthm-title} *some theorem*
:::

::: {.Theorem .amsthm .amsthm-plain}
[**Theorem 2.1.4.**]{.amsthm-title} *some theorem*
:::

#### Level 4

::: {.Theorem .amsthm .amsthm-plain}
[**Theorem 2.1.5.**]{.amsthm-title} *some theorem*
:::

::: {.Theorem .amsthm .amsthm-plain}
[**Theorem 2.1.6.**]{.amsthm-title} *some theorem*
:::

##### Level 5

::: {.Theorem .amsthm .amsthm-plain}
[**Theorem 2.1.7.**]{.amsthm-title} *some theorem*
:::

::: {.Theorem .amsthm .amsthm-plain}
[**Theorem 2.1.8.**]{.amsthm-title} *some theorem*
:::

###### Level 6

::: {.Theorem .amsthm .amsthm-plain}
[**Theorem 2.1.9.**]{.amsthm-title} *some theorem*
:::

::: {.Theorem .amsthm .amsthm-plain}
[**Theorem 2.1.10.**]{.amsthm-title} *some theorem*
:::
