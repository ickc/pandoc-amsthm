---
amsthm:
  plain:
  - Theorem: Lemma
  - With Space*
  definition:
  - Definition
  remark:
  - Case
  parentcounter:
  - chapter
...

<div class="Theorem" info="within parenthesis">
plain theoremstyle here
</div>

<div class="Theorem" id="simplestEquation"}
Label and reference:

$$E=mc^2$$
</div>

From the \ref{simplestEquation}, we see that...

<div class="With Space" info="within parenthesis">
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
