---
amsthm:	true
amsthm-plain:	Theorem
amsthm-plain-unnumbered:	[Lemma, Proposition, Corollary]
amsthm-def:	[Definition,Conjecture,Example,Postulate,Problem]
amsthm-def-unnumbered:	[]
amsthm-remark:	[Case]
amsthm-remark-unnumbered:	[Remark,Note]
amsthm-parentcounter:	chapter
title:	Pandoc with Amsthm Defined in YAML Front Matter
author:	Kolen Cheung
date:	2016-04-21
keywords:	pandoc, amsthm, LaTeX, yaml
toc-depth:	5
lang:	en
documentclass:	memoir
classoption:	oneside, article
colorlinks:	true
---

# First Heading #

<div latex="true" class="Theorem">
The Riemann zeta function is defined for complex $s$ with real part greater than $1$ by the absolutely convergent infinite series

$$\zeta(s) = \sum_{n=1}^\infty \frac{1}{n^s} = \frac{1}{1^s} + \frac{1}{2^s} + \frac{1}{3^s} + \cdots.$$
</div>

<div latex="true" class="Lemma">
The Riemann zeta function is defined for complex $s$ with real part greater than $1$ by the absolutely convergent infinite series

$$\zeta(s) = \sum_{n=1}^\infty \frac{1}{n^s} = \frac{1}{1^s} + \frac{1}{2^s} + \frac{1}{3^s} + \cdots.$$
</div>

<div latex="true" class="Proposition">
The Riemann zeta function is defined for complex $s$ with real part greater than $1$ by the absolutely convergent infinite series

$$\zeta(s) = \sum_{n=1}^\infty \frac{1}{n^s} = \frac{1}{1^s} + \frac{1}{2^s} + \frac{1}{3^s} + \cdots.$$
</div>

<div latex="true" class="Corollary">
The Riemann zeta function is defined for complex $s$ with real part greater than $1$ by the absolutely convergent infinite series

$$\zeta(s) = \sum_{n=1}^\infty \frac{1}{n^s} = \frac{1}{1^s} + \frac{1}{2^s} + \frac{1}{3^s} + \cdots.$$
</div>

<div latex="true" class="Definition">
Leonhard Euler showed that this series equals the Euler product

$$\zeta(s) = \prod_{p \text{ prime}} \frac{1}{1-p^{-s}}= \frac{1}{1-2^{-s}}\cdot\frac{1}{1-3^{-s}}\cdot\frac{1}{1-5^{-s}}\cdot\frac{1}{1-7^{-s}} \cdots \frac{1}{1-p^{-s}} \cdots$$
</div>

<div latex="true" class="Conjecture">
Leonhard Euler showed that this series equals the Euler product

$$\zeta(s) = \prod_{p \text{ prime}} \frac{1}{1-p^{-s}}= \frac{1}{1-2^{-s}}\cdot\frac{1}{1-3^{-s}}\cdot\frac{1}{1-5^{-s}}\cdot\frac{1}{1-7^{-s}} \cdots \frac{1}{1-p^{-s}} \cdots$$
</div>

<div latex="true" class="Example">
Leonhard Euler showed that this series equals the Euler product

$$\zeta(s) = \prod_{p \text{ prime}} \frac{1}{1-p^{-s}}= \frac{1}{1-2^{-s}}\cdot\frac{1}{1-3^{-s}}\cdot\frac{1}{1-5^{-s}}\cdot\frac{1}{1-7^{-s}} \cdots \frac{1}{1-p^{-s}} \cdots$$
</div>

<div latex="true" class="Postulate">
Leonhard Euler showed that this series equals the Euler product

$$\zeta(s) = \prod_{p \text{ prime}} \frac{1}{1-p^{-s}}= \frac{1}{1-2^{-s}}\cdot\frac{1}{1-3^{-s}}\cdot\frac{1}{1-5^{-s}}\cdot\frac{1}{1-7^{-s}} \cdots \frac{1}{1-p^{-s}} \cdots$$
</div>

<div latex="true" class="Problem">
Leonhard Euler showed that this series equals the Euler product

$$\zeta(s) = \prod_{p \text{ prime}} \frac{1}{1-p^{-s}}= \frac{1}{1-2^{-s}}\cdot\frac{1}{1-3^{-s}}\cdot\frac{1}{1-5^{-s}}\cdot\frac{1}{1-7^{-s}} \cdots \frac{1}{1-p^{-s}} \cdots$$
</div>

<div latex="true" class="Remark">
The Riemann zeta function is defined for complex $s$ with real part greater than $1$ by the absolutely convergent infinite series

$$\zeta(s) = \sum_{n=1}^\infty \frac{1}{n^s} = \frac{1}{1^s} + \frac{1}{2^s} + \frac{1}{3^s} + \cdots.$$
</div>

<div latex="true" class="Note">
The Riemann zeta function is defined for complex $s$ with real part greater than $1$ by the absolutely convergent infinite series

$$\zeta(s) = \sum_{n=1}^\infty \frac{1}{n^s} = \frac{1}{1^s} + \frac{1}{2^s} + \frac{1}{3^s} + \cdots.$$
</div>

<div latex="true" class="Case">
The Riemann zeta function is defined for complex $s$ with real part greater than $1$ by the absolutely convergent infinite series

$$\zeta(s) = \sum_{n=1}^\infty \frac{1}{n^s} = \frac{1}{1^s} + \frac{1}{2^s} + \frac{1}{3^s} + \cdots.$$
</div>

<div latex="true" class="proof">
Leonhard Euler showed that this series equals the Euler product

$$\zeta(s) = \prod_{p \text{ prime}} \frac{1}{1-p^{-s}}= \frac{1}{1-2^{-s}}\cdot\frac{1}{1-3^{-s}}\cdot\frac{1}{1-5^{-s}}\cdot\frac{1}{1-7^{-s}} \cdots \frac{1}{1-p^{-s}} \cdots$$
</div>

**Repeating once:**

<div latex="true" class="Theorem">
The Riemann zeta function is defined for complex $s$ with real part greater than $1$ by the absolutely convergent infinite series

$$\zeta(s) = \sum_{n=1}^\infty \frac{1}{n^s} = \frac{1}{1^s} + \frac{1}{2^s} + \frac{1}{3^s} + \cdots.$$
</div>

<div latex="true" class="Lemma">
The Riemann zeta function is defined for complex $s$ with real part greater than $1$ by the absolutely convergent infinite series

$$\zeta(s) = \sum_{n=1}^\infty \frac{1}{n^s} = \frac{1}{1^s} + \frac{1}{2^s} + \frac{1}{3^s} + \cdots.$$
</div>

<div latex="true" class="Proposition">
The Riemann zeta function is defined for complex $s$ with real part greater than $1$ by the absolutely convergent infinite series

$$\zeta(s) = \sum_{n=1}^\infty \frac{1}{n^s} = \frac{1}{1^s} + \frac{1}{2^s} + \frac{1}{3^s} + \cdots.$$
</div>

<div latex="true" class="Corollary">
The Riemann zeta function is defined for complex $s$ with real part greater than $1$ by the absolutely convergent infinite series

$$\zeta(s) = \sum_{n=1}^\infty \frac{1}{n^s} = \frac{1}{1^s} + \frac{1}{2^s} + \frac{1}{3^s} + \cdots.$$
</div>

<div latex="true" class="Definition">
Leonhard Euler showed that this series equals the Euler product

$$\zeta(s) = \prod_{p \text{ prime}} \frac{1}{1-p^{-s}}= \frac{1}{1-2^{-s}}\cdot\frac{1}{1-3^{-s}}\cdot\frac{1}{1-5^{-s}}\cdot\frac{1}{1-7^{-s}} \cdots \frac{1}{1-p^{-s}} \cdots$$
</div>

<div latex="true" class="Conjecture">
Leonhard Euler showed that this series equals the Euler product

$$\zeta(s) = \prod_{p \text{ prime}} \frac{1}{1-p^{-s}}= \frac{1}{1-2^{-s}}\cdot\frac{1}{1-3^{-s}}\cdot\frac{1}{1-5^{-s}}\cdot\frac{1}{1-7^{-s}} \cdots \frac{1}{1-p^{-s}} \cdots$$
</div>

<div latex="true" class="Example">
Leonhard Euler showed that this series equals the Euler product

$$\zeta(s) = \prod_{p \text{ prime}} \frac{1}{1-p^{-s}}= \frac{1}{1-2^{-s}}\cdot\frac{1}{1-3^{-s}}\cdot\frac{1}{1-5^{-s}}\cdot\frac{1}{1-7^{-s}} \cdots \frac{1}{1-p^{-s}} \cdots$$
</div>

<div latex="true" class="Postulate">
Leonhard Euler showed that this series equals the Euler product

$$\zeta(s) = \prod_{p \text{ prime}} \frac{1}{1-p^{-s}}= \frac{1}{1-2^{-s}}\cdot\frac{1}{1-3^{-s}}\cdot\frac{1}{1-5^{-s}}\cdot\frac{1}{1-7^{-s}} \cdots \frac{1}{1-p^{-s}} \cdots$$
</div>

<div latex="true" class="Problem">
Leonhard Euler showed that this series equals the Euler product

$$\zeta(s) = \prod_{p \text{ prime}} \frac{1}{1-p^{-s}}= \frac{1}{1-2^{-s}}\cdot\frac{1}{1-3^{-s}}\cdot\frac{1}{1-5^{-s}}\cdot\frac{1}{1-7^{-s}} \cdots \frac{1}{1-p^{-s}} \cdots$$
</div>

<div latex="true" class="Remark">
The Riemann zeta function is defined for complex $s$ with real part greater than $1$ by the absolutely convergent infinite series

$$\zeta(s) = \sum_{n=1}^\infty \frac{1}{n^s} = \frac{1}{1^s} + \frac{1}{2^s} + \frac{1}{3^s} + \cdots.$$
</div>

<div latex="true" class="Note">
The Riemann zeta function is defined for complex $s$ with real part greater than $1$ by the absolutely convergent infinite series

$$\zeta(s) = \sum_{n=1}^\infty \frac{1}{n^s} = \frac{1}{1^s} + \frac{1}{2^s} + \frac{1}{3^s} + \cdots.$$
</div>

<div latex="true" class="Case">
The Riemann zeta function is defined for complex $s$ with real part greater than $1$ by the absolutely convergent infinite series

$$\zeta(s) = \sum_{n=1}^\infty \frac{1}{n^s} = \frac{1}{1^s} + \frac{1}{2^s} + \frac{1}{3^s} + \cdots.$$
</div>

<div latex="true" class="proof">
Leonhard Euler showed that this series equals the Euler product

$$\zeta(s) = \prod_{p \text{ prime}} \frac{1}{1-p^{-s}}= \frac{1}{1-2^{-s}}\cdot\frac{1}{1-3^{-s}}\cdot\frac{1}{1-5^{-s}}\cdot\frac{1}{1-7^{-s}} \cdots \frac{1}{1-p^{-s}} \cdots$$
</div>

# Second Heading #

<div latex="true" class="Theorem">
The Riemann zeta function is defined for complex $s$ with real part greater than $1$ by the absolutely convergent infinite series

$$\zeta(s) = \sum_{n=1}^\infty \frac{1}{n^s} = \frac{1}{1^s} + \frac{1}{2^s} + \frac{1}{3^s} + \cdots.$$
</div>

<div latex="true" class="Lemma">
The Riemann zeta function is defined for complex $s$ with real part greater than $1$ by the absolutely convergent infinite series

$$\zeta(s) = \sum_{n=1}^\infty \frac{1}{n^s} = \frac{1}{1^s} + \frac{1}{2^s} + \frac{1}{3^s} + \cdots.$$
</div>

<div latex="true" class="Proposition">
The Riemann zeta function is defined for complex $s$ with real part greater than $1$ by the absolutely convergent infinite series

$$\zeta(s) = \sum_{n=1}^\infty \frac{1}{n^s} = \frac{1}{1^s} + \frac{1}{2^s} + \frac{1}{3^s} + \cdots.$$
</div>

<div latex="true" class="Corollary">
The Riemann zeta function is defined for complex $s$ with real part greater than $1$ by the absolutely convergent infinite series

$$\zeta(s) = \sum_{n=1}^\infty \frac{1}{n^s} = \frac{1}{1^s} + \frac{1}{2^s} + \frac{1}{3^s} + \cdots.$$
</div>

<div latex="true" class="Definition">
Leonhard Euler showed that this series equals the Euler product

$$\zeta(s) = \prod_{p \text{ prime}} \frac{1}{1-p^{-s}}= \frac{1}{1-2^{-s}}\cdot\frac{1}{1-3^{-s}}\cdot\frac{1}{1-5^{-s}}\cdot\frac{1}{1-7^{-s}} \cdots \frac{1}{1-p^{-s}} \cdots$$
</div>

<div latex="true" class="Conjecture">
Leonhard Euler showed that this series equals the Euler product

$$\zeta(s) = \prod_{p \text{ prime}} \frac{1}{1-p^{-s}}= \frac{1}{1-2^{-s}}\cdot\frac{1}{1-3^{-s}}\cdot\frac{1}{1-5^{-s}}\cdot\frac{1}{1-7^{-s}} \cdots \frac{1}{1-p^{-s}} \cdots$$
</div>

<div latex="true" class="Example">
Leonhard Euler showed that this series equals the Euler product

$$\zeta(s) = \prod_{p \text{ prime}} \frac{1}{1-p^{-s}}= \frac{1}{1-2^{-s}}\cdot\frac{1}{1-3^{-s}}\cdot\frac{1}{1-5^{-s}}\cdot\frac{1}{1-7^{-s}} \cdots \frac{1}{1-p^{-s}} \cdots$$
</div>

<div latex="true" class="Postulate">
Leonhard Euler showed that this series equals the Euler product

$$\zeta(s) = \prod_{p \text{ prime}} \frac{1}{1-p^{-s}}= \frac{1}{1-2^{-s}}\cdot\frac{1}{1-3^{-s}}\cdot\frac{1}{1-5^{-s}}\cdot\frac{1}{1-7^{-s}} \cdots \frac{1}{1-p^{-s}} \cdots$$
</div>

<div latex="true" class="Problem">
Leonhard Euler showed that this series equals the Euler product

$$\zeta(s) = \prod_{p \text{ prime}} \frac{1}{1-p^{-s}}= \frac{1}{1-2^{-s}}\cdot\frac{1}{1-3^{-s}}\cdot\frac{1}{1-5^{-s}}\cdot\frac{1}{1-7^{-s}} \cdots \frac{1}{1-p^{-s}} \cdots$$
</div>

<div latex="true" class="Remark">
The Riemann zeta function is defined for complex $s$ with real part greater than $1$ by the absolutely convergent infinite series

$$\zeta(s) = \sum_{n=1}^\infty \frac{1}{n^s} = \frac{1}{1^s} + \frac{1}{2^s} + \frac{1}{3^s} + \cdots.$$
</div>

<div latex="true" class="Note">
The Riemann zeta function is defined for complex $s$ with real part greater than $1$ by the absolutely convergent infinite series

$$\zeta(s) = \sum_{n=1}^\infty \frac{1}{n^s} = \frac{1}{1^s} + \frac{1}{2^s} + \frac{1}{3^s} + \cdots.$$
</div>

<div latex="true" class="Case">
The Riemann zeta function is defined for complex $s$ with real part greater than $1$ by the absolutely convergent infinite series

$$\zeta(s) = \sum_{n=1}^\infty \frac{1}{n^s} = \frac{1}{1^s} + \frac{1}{2^s} + \frac{1}{3^s} + \cdots.$$
</div>

<div latex="true" class="proof">
Leonhard Euler showed that this series equals the Euler product

$$\zeta(s) = \prod_{p \text{ prime}} \frac{1}{1-p^{-s}}= \frac{1}{1-2^{-s}}\cdot\frac{1}{1-3^{-s}}\cdot\frac{1}{1-5^{-s}}\cdot\frac{1}{1-7^{-s}} \cdots \frac{1}{1-p^{-s}} \cdots$$
</div>

## Subheading ##

<div latex="true" class="Theorem">
The Riemann zeta function is defined for complex $s$ with real part greater than $1$ by the absolutely convergent infinite series

$$\zeta(s) = \sum_{n=1}^\infty \frac{1}{n^s} = \frac{1}{1^s} + \frac{1}{2^s} + \frac{1}{3^s} + \cdots.$$
</div>

<div latex="true" class="Lemma">
The Riemann zeta function is defined for complex $s$ with real part greater than $1$ by the absolutely convergent infinite series

$$\zeta(s) = \sum_{n=1}^\infty \frac{1}{n^s} = \frac{1}{1^s} + \frac{1}{2^s} + \frac{1}{3^s} + \cdots.$$
</div>

<div latex="true" class="Proposition">
The Riemann zeta function is defined for complex $s$ with real part greater than $1$ by the absolutely convergent infinite series

$$\zeta(s) = \sum_{n=1}^\infty \frac{1}{n^s} = \frac{1}{1^s} + \frac{1}{2^s} + \frac{1}{3^s} + \cdots.$$
</div>

<div latex="true" class="Corollary">
The Riemann zeta function is defined for complex $s$ with real part greater than $1$ by the absolutely convergent infinite series

$$\zeta(s) = \sum_{n=1}^\infty \frac{1}{n^s} = \frac{1}{1^s} + \frac{1}{2^s} + \frac{1}{3^s} + \cdots.$$
</div>

<div latex="true" class="Definition">
Leonhard Euler showed that this series equals the Euler product

$$\zeta(s) = \prod_{p \text{ prime}} \frac{1}{1-p^{-s}}= \frac{1}{1-2^{-s}}\cdot\frac{1}{1-3^{-s}}\cdot\frac{1}{1-5^{-s}}\cdot\frac{1}{1-7^{-s}} \cdots \frac{1}{1-p^{-s}} \cdots$$
</div>

<div latex="true" class="Conjecture">
Leonhard Euler showed that this series equals the Euler product

$$\zeta(s) = \prod_{p \text{ prime}} \frac{1}{1-p^{-s}}= \frac{1}{1-2^{-s}}\cdot\frac{1}{1-3^{-s}}\cdot\frac{1}{1-5^{-s}}\cdot\frac{1}{1-7^{-s}} \cdots \frac{1}{1-p^{-s}} \cdots$$
</div>

<div latex="true" class="Example">
Leonhard Euler showed that this series equals the Euler product

$$\zeta(s) = \prod_{p \text{ prime}} \frac{1}{1-p^{-s}}= \frac{1}{1-2^{-s}}\cdot\frac{1}{1-3^{-s}}\cdot\frac{1}{1-5^{-s}}\cdot\frac{1}{1-7^{-s}} \cdots \frac{1}{1-p^{-s}} \cdots$$
</div>

<div latex="true" class="Postulate">
Leonhard Euler showed that this series equals the Euler product

$$\zeta(s) = \prod_{p \text{ prime}} \frac{1}{1-p^{-s}}= \frac{1}{1-2^{-s}}\cdot\frac{1}{1-3^{-s}}\cdot\frac{1}{1-5^{-s}}\cdot\frac{1}{1-7^{-s}} \cdots \frac{1}{1-p^{-s}} \cdots$$
</div>

<div latex="true" class="Problem">
Leonhard Euler showed that this series equals the Euler product

$$\zeta(s) = \prod_{p \text{ prime}} \frac{1}{1-p^{-s}}= \frac{1}{1-2^{-s}}\cdot\frac{1}{1-3^{-s}}\cdot\frac{1}{1-5^{-s}}\cdot\frac{1}{1-7^{-s}} \cdots \frac{1}{1-p^{-s}} \cdots$$
</div>

<div latex="true" class="Remark">
The Riemann zeta function is defined for complex $s$ with real part greater than $1$ by the absolutely convergent infinite series

$$\zeta(s) = \sum_{n=1}^\infty \frac{1}{n^s} = \frac{1}{1^s} + \frac{1}{2^s} + \frac{1}{3^s} + \cdots.$$
</div>

<div latex="true" class="Note">
The Riemann zeta function is defined for complex $s$ with real part greater than $1$ by the absolutely convergent infinite series

$$\zeta(s) = \sum_{n=1}^\infty \frac{1}{n^s} = \frac{1}{1^s} + \frac{1}{2^s} + \frac{1}{3^s} + \cdots.$$
</div>

<div latex="true" class="Case">
The Riemann zeta function is defined for complex $s$ with real part greater than $1$ by the absolutely convergent infinite series

$$\zeta(s) = \sum_{n=1}^\infty \frac{1}{n^s} = \frac{1}{1^s} + \frac{1}{2^s} + \frac{1}{3^s} + \cdots.$$
</div>

<div latex="true" class="proof">
Leonhard Euler showed that this series equals the Euler product

$$\zeta(s) = \prod_{p \text{ prime}} \frac{1}{1-p^{-s}}= \frac{1}{1-2^{-s}}\cdot\frac{1}{1-3^{-s}}\cdot\frac{1}{1-5^{-s}}\cdot\frac{1}{1-7^{-s}} \cdots \frac{1}{1-p^{-s}} \cdots$$
</div>