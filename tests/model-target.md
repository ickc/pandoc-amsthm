# Demo

::: {.Theorem info="within parenthesis"}
**Theorem 1.0.1** (within parenthesis)**.** *plain* *theoremstyle* here
:::

::: {#simplestEquation .Theorem}
**Theorem 1.0.2.** *Label* *and* *reference:*

$$E=mc^2$$
:::

From the 1.0.2, we see that...

Or we can use pandoc-crossref style 1.0.2 as well.

::: {.With_Space info="**This** is *markdown*."}
**With Space** (**This** is *markdown*.)**.** *Environment* *name* *has*
*a* *space,* *and* *is* *unnumbered.*
:::

::: {.Lemma info="can cite \\ref{simplestEquation}"}
**Lemma 1.0.3** (can cite 1.0.2)**.** *This* *one* *share* *counter*
*with* *Theorem.*

*Cite* *inside* *info* *only* *works* *with* `ref{...}` *syntax.* *As*
*the* *conversion* *using* `[@...]` *to* *AST* *and* *walk* *and* *back*
*to* *LaTeX* *would* *be* *too* *complex.*
:::

::: {.Definition info="within parenthesis"}
**Definition 1.0.1** (within parenthesis)**.** definition theoremstyle
here
:::

::: {.Case info="within parenthesis"}
*Case* 1.0.1 (within parenthesis)*.* remark theoremstyle here
:::

::: {.proof info="Proof of the Main Theorem"}
*Proof* *of* *the* *Main* *Theorem**.* Predefined proof theoremstyle
here`<span style='float: right'>◻</span>`{=html}
:::

::: {.proof info="Proof of the *little* theorem"}
*Proof* *of* *the* little *theorem**.* Predefined proof theoremstyle
here with markdown info.`<span style='float: right'>◻</span>`{=html}
:::

::: proof
*Proof.* Bare proof here.`<span style='float: right'>◻</span>`{=html}
:::

::: KL
**Klein's Lemma 1.0.1.** *Klein's* *Lemma* *from* *amsthm* *doc.*
:::

::: Definition
**Definition 1.0.2.**

    code here
:::

# Counter test

::: Theorem
**Theorem 2.0.1.** *some* *theorem*
:::

::: Theorem
**Theorem 2.0.2.** *some* *theorem*
:::

## Next level

::: Theorem
**Theorem 2.1.1.** *some* *theorem*
:::

::: Theorem
**Theorem 2.1.2.** *some* *theorem*
:::

### Level 3

::: Theorem
**Theorem 2.1.3.** *some* *theorem*
:::

::: Theorem
**Theorem 2.1.4.** *some* *theorem*
:::

#### Level 4

::: Theorem
**Theorem 2.1.5.** *some* *theorem*
:::

::: Theorem
**Theorem 2.1.6.** *some* *theorem*
:::

##### Level 5

::: Theorem
**Theorem 2.1.7.** *some* *theorem*
:::

::: Theorem
**Theorem 2.1.8.** *some* *theorem*
:::

###### Level 6

::: Theorem
**Theorem 2.1.9.** *some* *theorem*
:::

::: Theorem
**Theorem 2.1.10.** *some* *theorem*
:::
