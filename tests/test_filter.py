from unittest import TestCase
from pathlib import Path

from panflute.tools import convert_text

from amsthm import main

DIR = Path(__file__).parent

class TestAmsthm(TestCase):

    def setUp(self):
        with (DIR / "model-source.md").open("r") as f:
            self.text = f.read()
        with (DIR / "model-latex.tex").open("r") as f:
            self.ref_latex = f.read()

    def test_filter_latex(self):
        doc = convert_text(self.text, standalone=True)
        # force to convert to latex
        doc.format = "latex"
        main(doc)
        res = convert_text(doc, input_format="panflute", output_format="latex")
        assert res.strip() == self.ref_latex.strip()
