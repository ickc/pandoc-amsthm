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

<div class="Theorem" info="within parenthesis">
plain theoremstyle here
</div>

<div class="Theorem" id="simplestEquation">
Label and reference:

$$E=mc^2$$
</div>

From the \ref{simplestEquation}, we see that...

<div class="With_Space" info="within parenthesis">
Environment name has a space, and is unnumbered.
</div>

<div class="Lemma" info="within parenthesis">
This one share counter with Theorem
</div>

<div class="Definition" info="within parenthesis">
definition theoremstyle here
</div>

<div class="Case" info="within parenthesis">
remark theoremstyle here
</div>

<div class="proof" info="Proof of the Main Theorem">
Predefined proof theoremstyle here
</div>