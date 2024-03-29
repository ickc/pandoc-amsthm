.. contents::
   :depth: 3
..

.. section-numbering::

.. raw:: latex

   \usepackage{amsthm}

Demo
====

.. container:: Theorem

   **Theorem 1.0.1** (within parenthesis)\ **.** *plain theoremstyle*
   here

   *We can use pandoc-crossref style* 1.0.2 *and* (1.0.2) *and cite
   before definition.*

.. container:: Theorem
   :name: simplestEquation

   **Theorem 1.0.2.** *Label and reference:*

   .. math:: E=mc^2

From the 1.0.2, we see that… Or (1.0.2), …

.. container:: With_Space

   **With Space** (**This** is *markdown*.)\ **.** *Environment name has
   a space, and is unnumbered.*

.. container:: Lemma

   **Lemma 1.0.3** (can cite 1.0.2)\ **.** *This one share counter with
   Theorem.*

.. container:: Definition

   **Definition 1.0.1** (pandoc-crossref style cite 1.0.2)\ **.**
   definition theoremstyle here

.. container:: Case

   *Case* 1.0.1 (within parenthesis)\ *.* remark theoremstyle here

.. container:: proof

   *Proof of the Main Theorem*\ *.* Predefined proof theoremstyle here

.. container:: proof

   *Proof of the* little *theorem*\ *.* Predefined proof theoremstyle
   here with markdown info.

.. container:: proof

   *Proof.* Bare proof here.

.. container:: KL

   **Klein’s Lemma 1.0.1.** *Klein’s Lemma from amsthm doc.*

.. container:: Definition

   **Definition 1.0.2.**

   ::

      code here

Counter test
============

.. container:: Theorem

   **Theorem 2.0.1.** *some theorem*

.. container:: Theorem

   **Theorem 2.0.2.** *some theorem*

Next level
----------

.. container:: Theorem

   **Theorem 2.1.1.** *some theorem*

.. container:: Theorem

   **Theorem 2.1.2.** *some theorem*

Level 3
~~~~~~~

.. container:: Theorem

   **Theorem 2.1.3.** *some theorem*

.. container:: Theorem

   **Theorem 2.1.4.** *some theorem*

Level 4
^^^^^^^

.. container:: Theorem

   **Theorem 2.1.5.** *some theorem*

.. container:: Theorem

   **Theorem 2.1.6.** *some theorem*

Level 5
'''''''

.. container:: Theorem

   **Theorem 2.1.7.** *some theorem*

.. container:: Theorem

   **Theorem 2.1.8.** *some theorem*

Level 6
       

.. container:: Theorem

   **Theorem 2.1.9.** *some theorem*

.. container:: Theorem

   **Theorem 2.1.10.** *some theorem*
