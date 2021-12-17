from copy import deepcopy
from pathlib import Path
from unittest import TestCase

import panflute as pf
from panflute.tools import convert_text

from amsthm import cancel_emph, merge_emph, to_emph

DIR = Path(__file__).parent


class TestAmsthm(TestCase):
    def setUp(self):
        self.simple = pf.Para(pf.Str("a"), pf.Space, pf.Str("b"))
        self.ast = pf.Para(pf.Emph(pf.Str("a")), pf.Emph(pf.Str("b")))
        self.ast2 = pf.Para(pf.Emph(pf.Str("a")), pf.Space, pf.Emph(pf.Str("b")))
        self.ast_double_emph = pf.Para(pf.Emph(pf.Emph(pf.Str("a"))), pf.Space, pf.Emph(pf.Str("b")))
        self.combined = pf.Para(
            pf.Emph(pf.Str("a")),
            pf.Emph(pf.Str("b")),
            pf.Space,
            pf.Str("c"),
            pf.Str("d"),
        )

    def test_to_emph_simple(self):
        ast = deepcopy(self.simple)
        ast.walk(to_emph)
        res = convert_text(ast, input_format="panflute", output_format="markdown")
        assert res == "*a* *b*"

    def test_cancel_emph(self):
        ast = deepcopy(self.ast_double_emph)
        ast.walk(cancel_emph)
        res = convert_text(ast, input_format="panflute", output_format="markdown")
        assert res == "a *b*"

    def test_merge_emph(self):
        ast = deepcopy(self.ast)
        ast.walk(merge_emph)
        res = convert_text(ast, input_format="panflute", output_format="markdown")
        assert res == "*ab*"

    def test_merge_emph2(self):
        ast = deepcopy(self.ast2)
        ast.walk(merge_emph)
        res = convert_text(ast, input_format="panflute", output_format="markdown")
        assert res == "*a b*"

    def test_all_emph_together(self):
        ast = deepcopy(self.combined)
        ast.walk(to_emph)
        ast.walk(cancel_emph)
        ast.walk(merge_emph)
        res = convert_text(ast, input_format="panflute", output_format="markdown")
        assert res == "ab *cd*"
