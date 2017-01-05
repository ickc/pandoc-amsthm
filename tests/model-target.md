---
fontfamily: lmodern, amsthm
amsthm:
  plain:
  - Theorem: [Lemma, Corollary]
  - With Space*
  - Proposition: Conjecture
  - WithoutSpace
  definition:
  - Definition
  remark:
  - Case
  parentcounter: chapter
...

# Demo

**Theorem 1.1** (within parenthesis). *plain theoremstyle here*

**Theorem 1.2.** *Label and reference:*

$$E=mc^2$$

From the 1.2, we see that...

**With Space** (within parenthesis). *Environment name has a space, and is unnumbered.*

**Lemma 1.3** (within parenthesis). *This one share counter with Theorem*

**Definition 1.1** (within parenthesis). definition theoremstyle here

*Case* 1.1 (within parenthesis). remark theoremstyle here

*Proof of the Main Theorem*. Predefined proof theoremstyle here <span style="float: right">&#9723;<span>
