---
amsthm:
  plain:	[Theorem]
  plain-unnumbered:	[Lemma, Proposition, Corollary]
  definition:	[Definition, Conjecture, Example, Postulate, Problem]
  definition-unnumbered:	[]
  remark:	[Case]
  remark-unnumbered:	[Remark, Note]
  proof:	[proof]
  parentcounter:	chapter
title:	Pandoc with Amsthm Defined in YAML Front Matter
author:	Kolen Cheung
date:	\today
keywords:	pandoc, amsthm, LaTeX, yaml
toc-depth:	5
lang:	en
documentclass:	memoir
classoption:	oneside, article
colorlinks:	true
---

# First Heading #

<div class="Theorem">
The Riemann zeta function is defined for complex $s$ with real part greater than $1$ by the absolutely convergent infinite series

$$\zeta(s) = \sum_{n=1}^\infty \frac{1}{n^s} = \frac{1}{1^s} + \frac{1}{2^s} + \frac{1}{3^s} + \cdots.$$
</div>

<div class="Lemma">
The Riemann zeta function is defined for complex $s$ with real part greater than $1$ by the absolutely convergent infinite series

$$\zeta(s) = \sum_{n=1}^\infty \frac{1}{n^s} = \frac{1}{1^s} + \frac{1}{2^s} + \frac{1}{3^s} + \cdots.$$
</div>

<div class="Proposition">
The Riemann zeta function is defined for complex $s$ with real part greater than $1$ by the absolutely convergent infinite series

$$\zeta(s) = \sum_{n=1}^\infty \frac{1}{n^s} = \frac{1}{1^s} + \frac{1}{2^s} + \frac{1}{3^s} + \cdots.$$
</div>

<div class="Corollary">
The Riemann zeta function is defined for complex $s$ with real part greater than $1$ by the absolutely convergent infinite series

$$\zeta(s) = \sum_{n=1}^\infty \frac{1}{n^s} = \frac{1}{1^s} + \frac{1}{2^s} + \frac{1}{3^s} + \cdots.$$
</div>

<div class="Definition">
Leonhard Euler showed that this series equals the Euler product

$$\zeta(s) = \prod_{p \text{ prime}} \frac{1}{1-p^{-s}}= \frac{1}{1-2^{-s}}\cdot\frac{1}{1-3^{-s}}\cdot\frac{1}{1-5^{-s}}\cdot\frac{1}{1-7^{-s}} \cdots \frac{1}{1-p^{-s}} \cdots$$
</div>

<div class="Conjecture">
Leonhard Euler showed that this series equals the Euler product

$$\zeta(s) = \prod_{p \text{ prime}} \frac{1}{1-p^{-s}}= \frac{1}{1-2^{-s}}\cdot\frac{1}{1-3^{-s}}\cdot\frac{1}{1-5^{-s}}\cdot\frac{1}{1-7^{-s}} \cdots \frac{1}{1-p^{-s}} \cdots$$
</div>

<div class="Example">
Leonhard Euler showed that this series equals the Euler product

$$\zeta(s) = \prod_{p \text{ prime}} \frac{1}{1-p^{-s}}= \frac{1}{1-2^{-s}}\cdot\frac{1}{1-3^{-s}}\cdot\frac{1}{1-5^{-s}}\cdot\frac{1}{1-7^{-s}} \cdots \frac{1}{1-p^{-s}} \cdots$$
</div>

<div class="Postulate">
Leonhard Euler showed that this series equals the Euler product

$$\zeta(s) = \prod_{p \text{ prime}} \frac{1}{1-p^{-s}}= \frac{1}{1-2^{-s}}\cdot\frac{1}{1-3^{-s}}\cdot\frac{1}{1-5^{-s}}\cdot\frac{1}{1-7^{-s}} \cdots \frac{1}{1-p^{-s}} \cdots$$
</div>

<div class="Problem">
Leonhard Euler showed that this series equals the Euler product

$$\zeta(s) = \prod_{p \text{ prime}} \frac{1}{1-p^{-s}}= \frac{1}{1-2^{-s}}\cdot\frac{1}{1-3^{-s}}\cdot\frac{1}{1-5^{-s}}\cdot\frac{1}{1-7^{-s}} \cdots \frac{1}{1-p^{-s}} \cdots$$
</div>

<div class="Remark">
The Riemann zeta function is defined for complex $s$ with real part greater than $1$ by the absolutely convergent infinite series

$$\zeta(s) = \sum_{n=1}^\infty \frac{1}{n^s} = \frac{1}{1^s} + \frac{1}{2^s} + \frac{1}{3^s} + \cdots.$$
</div>

<div class="Note">
The Riemann zeta function is defined for complex $s$ with real part greater than $1$ by the absolutely convergent infinite series

$$\zeta(s) = \sum_{n=1}^\infty \frac{1}{n^s} = \frac{1}{1^s} + \frac{1}{2^s} + \frac{1}{3^s} + \cdots.$$
</div>

<div class="Case">
The Riemann zeta function is defined for complex $s$ with real part greater than $1$ by the absolutely convergent infinite series

$$\zeta(s) = \sum_{n=1}^\infty \frac{1}{n^s} = \frac{1}{1^s} + \frac{1}{2^s} + \frac{1}{3^s} + \cdots.$$
</div>

<div class="proof">
Leonhard Euler showed that this series equals the Euler product

$$\zeta(s) = \prod_{p \text{ prime}} \frac{1}{1-p^{-s}}= \frac{1}{1-2^{-s}}\cdot\frac{1}{1-3^{-s}}\cdot\frac{1}{1-5^{-s}}\cdot\frac{1}{1-7^{-s}} \cdots \frac{1}{1-p^{-s}} \cdots$$
</div>

**Repeating once:**

<div class="Theorem">
The Riemann zeta function is defined for complex $s$ with real part greater than $1$ by the absolutely convergent infinite series

$$\zeta(s) = \sum_{n=1}^\infty \frac{1}{n^s} = \frac{1}{1^s} + \frac{1}{2^s} + \frac{1}{3^s} + \cdots.$$
</div>

<div class="Lemma">
The Riemann zeta function is defined for complex $s$ with real part greater than $1$ by the absolutely convergent infinite series

$$\zeta(s) = \sum_{n=1}^\infty \frac{1}{n^s} = \frac{1}{1^s} + \frac{1}{2^s} + \frac{1}{3^s} + \cdots.$$
</div>

<div class="Proposition">
The Riemann zeta function is defined for complex $s$ with real part greater than $1$ by the absolutely convergent infinite series

$$\zeta(s) = \sum_{n=1}^\infty \frac{1}{n^s} = \frac{1}{1^s} + \frac{1}{2^s} + \frac{1}{3^s} + \cdots.$$
</div>

<div class="Corollary">
The Riemann zeta function is defined for complex $s$ with real part greater than $1$ by the absolutely convergent infinite series

$$\zeta(s) = \sum_{n=1}^\infty \frac{1}{n^s} = \frac{1}{1^s} + \frac{1}{2^s} + \frac{1}{3^s} + \cdots.$$
</div>

<div class="Definition">
Leonhard Euler showed that this series equals the Euler product

$$\zeta(s) = \prod_{p \text{ prime}} \frac{1}{1-p^{-s}}= \frac{1}{1-2^{-s}}\cdot\frac{1}{1-3^{-s}}\cdot\frac{1}{1-5^{-s}}\cdot\frac{1}{1-7^{-s}} \cdots \frac{1}{1-p^{-s}} \cdots$$
</div>

<div class="Conjecture">
Leonhard Euler showed that this series equals the Euler product

$$\zeta(s) = \prod_{p \text{ prime}} \frac{1}{1-p^{-s}}= \frac{1}{1-2^{-s}}\cdot\frac{1}{1-3^{-s}}\cdot\frac{1}{1-5^{-s}}\cdot\frac{1}{1-7^{-s}} \cdots \frac{1}{1-p^{-s}} \cdots$$
</div>

<div class="Example">
Leonhard Euler showed that this series equals the Euler product

$$\zeta(s) = \prod_{p \text{ prime}} \frac{1}{1-p^{-s}}= \frac{1}{1-2^{-s}}\cdot\frac{1}{1-3^{-s}}\cdot\frac{1}{1-5^{-s}}\cdot\frac{1}{1-7^{-s}} \cdots \frac{1}{1-p^{-s}} \cdots$$
</div>

<div class="Postulate">
Leonhard Euler showed that this series equals the Euler product

$$\zeta(s) = \prod_{p \text{ prime}} \frac{1}{1-p^{-s}}= \frac{1}{1-2^{-s}}\cdot\frac{1}{1-3^{-s}}\cdot\frac{1}{1-5^{-s}}\cdot\frac{1}{1-7^{-s}} \cdots \frac{1}{1-p^{-s}} \cdots$$
</div>

<div class="Problem">
Leonhard Euler showed that this series equals the Euler product

$$\zeta(s) = \prod_{p \text{ prime}} \frac{1}{1-p^{-s}}= \frac{1}{1-2^{-s}}\cdot\frac{1}{1-3^{-s}}\cdot\frac{1}{1-5^{-s}}\cdot\frac{1}{1-7^{-s}} \cdots \frac{1}{1-p^{-s}} \cdots$$
</div>

<div class="Remark">
The Riemann zeta function is defined for complex $s$ with real part greater than $1$ by the absolutely convergent infinite series

$$\zeta(s) = \sum_{n=1}^\infty \frac{1}{n^s} = \frac{1}{1^s} + \frac{1}{2^s} + \frac{1}{3^s} + \cdots.$$
</div>

<div class="Note">
The Riemann zeta function is defined for complex $s$ with real part greater than $1$ by the absolutely convergent infinite series

$$\zeta(s) = \sum_{n=1}^\infty \frac{1}{n^s} = \frac{1}{1^s} + \frac{1}{2^s} + \frac{1}{3^s} + \cdots.$$
</div>

<div class="Case">
The Riemann zeta function is defined for complex $s$ with real part greater than $1$ by the absolutely convergent infinite series

$$\zeta(s) = \sum_{n=1}^\infty \frac{1}{n^s} = \frac{1}{1^s} + \frac{1}{2^s} + \frac{1}{3^s} + \cdots.$$
</div>

<div class="proof">
Leonhard Euler showed that this series equals the Euler product

$$\zeta(s) = \prod_{p \text{ prime}} \frac{1}{1-p^{-s}}= \frac{1}{1-2^{-s}}\cdot\frac{1}{1-3^{-s}}\cdot\frac{1}{1-5^{-s}}\cdot\frac{1}{1-7^{-s}} \cdots \frac{1}{1-p^{-s}} \cdots$$
</div>

# Second Heading #

<div class="Theorem">
The Riemann zeta function is defined for complex $s$ with real part greater than $1$ by the absolutely convergent infinite series

$$\zeta(s) = \sum_{n=1}^\infty \frac{1}{n^s} = \frac{1}{1^s} + \frac{1}{2^s} + \frac{1}{3^s} + \cdots.$$
</div>

<div class="Lemma">
The Riemann zeta function is defined for complex $s$ with real part greater than $1$ by the absolutely convergent infinite series

$$\zeta(s) = \sum_{n=1}^\infty \frac{1}{n^s} = \frac{1}{1^s} + \frac{1}{2^s} + \frac{1}{3^s} + \cdots.$$
</div>

<div class="Proposition">
The Riemann zeta function is defined for complex $s$ with real part greater than $1$ by the absolutely convergent infinite series

$$\zeta(s) = \sum_{n=1}^\infty \frac{1}{n^s} = \frac{1}{1^s} + \frac{1}{2^s} + \frac{1}{3^s} + \cdots.$$
</div>

<div class="Corollary">
The Riemann zeta function is defined for complex $s$ with real part greater than $1$ by the absolutely convergent infinite series

$$\zeta(s) = \sum_{n=1}^\infty \frac{1}{n^s} = \frac{1}{1^s} + \frac{1}{2^s} + \frac{1}{3^s} + \cdots.$$
</div>

<div class="Definition">
Leonhard Euler showed that this series equals the Euler product

$$\zeta(s) = \prod_{p \text{ prime}} \frac{1}{1-p^{-s}}= \frac{1}{1-2^{-s}}\cdot\frac{1}{1-3^{-s}}\cdot\frac{1}{1-5^{-s}}\cdot\frac{1}{1-7^{-s}} \cdots \frac{1}{1-p^{-s}} \cdots$$
</div>

<div class="Conjecture">
Leonhard Euler showed that this series equals the Euler product

$$\zeta(s) = \prod_{p \text{ prime}} \frac{1}{1-p^{-s}}= \frac{1}{1-2^{-s}}\cdot\frac{1}{1-3^{-s}}\cdot\frac{1}{1-5^{-s}}\cdot\frac{1}{1-7^{-s}} \cdots \frac{1}{1-p^{-s}} \cdots$$
</div>

<div class="Example">
Leonhard Euler showed that this series equals the Euler product

$$\zeta(s) = \prod_{p \text{ prime}} \frac{1}{1-p^{-s}}= \frac{1}{1-2^{-s}}\cdot\frac{1}{1-3^{-s}}\cdot\frac{1}{1-5^{-s}}\cdot\frac{1}{1-7^{-s}} \cdots \frac{1}{1-p^{-s}} \cdots$$
</div>

<div class="Postulate">
Leonhard Euler showed that this series equals the Euler product

$$\zeta(s) = \prod_{p \text{ prime}} \frac{1}{1-p^{-s}}= \frac{1}{1-2^{-s}}\cdot\frac{1}{1-3^{-s}}\cdot\frac{1}{1-5^{-s}}\cdot\frac{1}{1-7^{-s}} \cdots \frac{1}{1-p^{-s}} \cdots$$
</div>

<div class="Problem">
Leonhard Euler showed that this series equals the Euler product

$$\zeta(s) = \prod_{p \text{ prime}} \frac{1}{1-p^{-s}}= \frac{1}{1-2^{-s}}\cdot\frac{1}{1-3^{-s}}\cdot\frac{1}{1-5^{-s}}\cdot\frac{1}{1-7^{-s}} \cdots \frac{1}{1-p^{-s}} \cdots$$
</div>

<div class="Remark">
The Riemann zeta function is defined for complex $s$ with real part greater than $1$ by the absolutely convergent infinite series

$$\zeta(s) = \sum_{n=1}^\infty \frac{1}{n^s} = \frac{1}{1^s} + \frac{1}{2^s} + \frac{1}{3^s} + \cdots.$$
</div>

<div class="Note">
The Riemann zeta function is defined for complex $s$ with real part greater than $1$ by the absolutely convergent infinite series

$$\zeta(s) = \sum_{n=1}^\infty \frac{1}{n^s} = \frac{1}{1^s} + \frac{1}{2^s} + \frac{1}{3^s} + \cdots.$$
</div>

<div class="Case">
The Riemann zeta function is defined for complex $s$ with real part greater than $1$ by the absolutely convergent infinite series

$$\zeta(s) = \sum_{n=1}^\infty \frac{1}{n^s} = \frac{1}{1^s} + \frac{1}{2^s} + \frac{1}{3^s} + \cdots.$$
</div>

<div class="proof">
Leonhard Euler showed that this series equals the Euler product

$$\zeta(s) = \prod_{p \text{ prime}} \frac{1}{1-p^{-s}}= \frac{1}{1-2^{-s}}\cdot\frac{1}{1-3^{-s}}\cdot\frac{1}{1-5^{-s}}\cdot\frac{1}{1-7^{-s}} \cdots \frac{1}{1-p^{-s}} \cdots$$
</div>

## Subheading ##

<div class="Theorem">
The Riemann zeta function is defined for complex $s$ with real part greater than $1$ by the absolutely convergent infinite series

$$\zeta(s) = \sum_{n=1}^\infty \frac{1}{n^s} = \frac{1}{1^s} + \frac{1}{2^s} + \frac{1}{3^s} + \cdots.$$
</div>

<div class="Lemma">
The Riemann zeta function is defined for complex $s$ with real part greater than $1$ by the absolutely convergent infinite series

$$\zeta(s) = \sum_{n=1}^\infty \frac{1}{n^s} = \frac{1}{1^s} + \frac{1}{2^s} + \frac{1}{3^s} + \cdots.$$
</div>

<div class="Proposition">
The Riemann zeta function is defined for complex $s$ with real part greater than $1$ by the absolutely convergent infinite series

$$\zeta(s) = \sum_{n=1}^\infty \frac{1}{n^s} = \frac{1}{1^s} + \frac{1}{2^s} + \frac{1}{3^s} + \cdots.$$
</div>

<div class="Corollary">
The Riemann zeta function is defined for complex $s$ with real part greater than $1$ by the absolutely convergent infinite series

$$\zeta(s) = \sum_{n=1}^\infty \frac{1}{n^s} = \frac{1}{1^s} + \frac{1}{2^s} + \frac{1}{3^s} + \cdots.$$
</div>

<div class="Definition">
Leonhard Euler showed that this series equals the Euler product

$$\zeta(s) = \prod_{p \text{ prime}} \frac{1}{1-p^{-s}}= \frac{1}{1-2^{-s}}\cdot\frac{1}{1-3^{-s}}\cdot\frac{1}{1-5^{-s}}\cdot\frac{1}{1-7^{-s}} \cdots \frac{1}{1-p^{-s}} \cdots$$
</div>

<div class="Conjecture">
Leonhard Euler showed that this series equals the Euler product

$$\zeta(s) = \prod_{p \text{ prime}} \frac{1}{1-p^{-s}}= \frac{1}{1-2^{-s}}\cdot\frac{1}{1-3^{-s}}\cdot\frac{1}{1-5^{-s}}\cdot\frac{1}{1-7^{-s}} \cdots \frac{1}{1-p^{-s}} \cdots$$
</div>

<div class="Example">
Leonhard Euler showed that this series equals the Euler product

$$\zeta(s) = \prod_{p \text{ prime}} \frac{1}{1-p^{-s}}= \frac{1}{1-2^{-s}}\cdot\frac{1}{1-3^{-s}}\cdot\frac{1}{1-5^{-s}}\cdot\frac{1}{1-7^{-s}} \cdots \frac{1}{1-p^{-s}} \cdots$$
</div>

<div class="Postulate">
Leonhard Euler showed that this series equals the Euler product

$$\zeta(s) = \prod_{p \text{ prime}} \frac{1}{1-p^{-s}}= \frac{1}{1-2^{-s}}\cdot\frac{1}{1-3^{-s}}\cdot\frac{1}{1-5^{-s}}\cdot\frac{1}{1-7^{-s}} \cdots \frac{1}{1-p^{-s}} \cdots$$
</div>

<div class="Problem">
Leonhard Euler showed that this series equals the Euler product

$$\zeta(s) = \prod_{p \text{ prime}} \frac{1}{1-p^{-s}}= \frac{1}{1-2^{-s}}\cdot\frac{1}{1-3^{-s}}\cdot\frac{1}{1-5^{-s}}\cdot\frac{1}{1-7^{-s}} \cdots \frac{1}{1-p^{-s}} \cdots$$
</div>

<div class="Remark">
The Riemann zeta function is defined for complex $s$ with real part greater than $1$ by the absolutely convergent infinite series

$$\zeta(s) = \sum_{n=1}^\infty \frac{1}{n^s} = \frac{1}{1^s} + \frac{1}{2^s} + \frac{1}{3^s} + \cdots.$$
</div>

<div class="Note">
The Riemann zeta function is defined for complex $s$ with real part greater than $1$ by the absolutely convergent infinite series

$$\zeta(s) = \sum_{n=1}^\infty \frac{1}{n^s} = \frac{1}{1^s} + \frac{1}{2^s} + \frac{1}{3^s} + \cdots.$$
</div>

<div class="Case">
The Riemann zeta function is defined for complex $s$ with real part greater than $1$ by the absolutely convergent infinite series

$$\zeta(s) = \sum_{n=1}^\infty \frac{1}{n^s} = \frac{1}{1^s} + \frac{1}{2^s} + \frac{1}{3^s} + \cdots.$$
</div>

<div class="proof">
Leonhard Euler showed that this series equals the Euler product

$$\zeta(s) = \prod_{p \text{ prime}} \frac{1}{1-p^{-s}}= \frac{1}{1-2^{-s}}\cdot\frac{1}{1-3^{-s}}\cdot\frac{1}{1-5^{-s}}\cdot\frac{1}{1-7^{-s}} \cdots \frac{1}{1-p^{-s}} \cdots$$
</div>

# Test

<div class="proof Theorem">
This one has 2 amsthm classes, which should be disallowed.
</div>

<div class="Theorem boxed">
This one has multiple classes, where only 1 of them is amsthm class ,this should be valid.
</div>