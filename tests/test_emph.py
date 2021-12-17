from copy import deepcopy
from functools import partial
from pathlib import Path
from unittest import TestCase

import panflute as pf
from panflute.tools import convert_text

from amsthm.helper import cancel_repeated_type, merge_consecutive_type, to_type

DIR = Path(__file__).parent


class TestEmph(TestCase):
    ElementType = pf.Emph

    def setUp(self):
        self.simple = pf.Para(pf.Str("a"), pf.Space, pf.Str("b"))
        self.ast = pf.Para(self.ElementType(pf.Str("a")), self.ElementType(pf.Str("b")))
        self.ast2 = pf.Para(self.ElementType(pf.Str("a")), pf.Space, self.ElementType(pf.Str("b")))
        self.ast_double_type = pf.Para(
            self.ElementType(self.ElementType(pf.Str("a"))), pf.Space, self.ElementType(pf.Str("b"))
        )
        self.combined = pf.Para(
            self.ElementType(pf.Str("a")),
            self.ElementType(pf.Str("b")),
            pf.Space,
            pf.Str("c"),
            pf.Str("d"),
        )
        self.to_type = partial(to_type, ElementType=self.ElementType)
        self.cancel_repeated_type = partial(cancel_repeated_type, ElementType=self.ElementType)
        self.merge_consecutive_type = partial(merge_consecutive_type, ElementType=self.ElementType)

    def test_to_emph_simple(self):
        ast = deepcopy(self.simple)
        ast.walk(self.to_type)
        res = convert_text(ast, input_format="panflute", output_format="native")
        ref = pf.Para(self.ElementType(pf.Str("a")), pf.Space, self.ElementType(pf.Str("b")))
        ref_native = convert_text(ref, input_format="panflute", output_format="native")
        assert res == ref_native

    def test_cancel_emph(self):
        ast = deepcopy(self.ast_double_type)
        ast.walk(self.cancel_repeated_type)
        res = convert_text(ast, input_format="panflute", output_format="native")
        ref = pf.Para(pf.Str("a"), pf.Space, self.ElementType(pf.Str("b")))
        ref_native = convert_text(ref, input_format="panflute", output_format="native")
        assert res == ref_native

    def test_merge_emph(self):
        ast = deepcopy(self.ast)
        ast.walk(self.merge_consecutive_type)
        res = convert_text(ast, input_format="panflute", output_format="native")
        ref = pf.Para(self.ElementType(pf.Str("a"), pf.Str("b")))
        ref_native = convert_text(ref, input_format="panflute", output_format="native")
        assert res == ref_native

    def test_merge_emph2(self):
        ast = deepcopy(self.ast2)
        ast.walk(self.merge_consecutive_type)
        res = convert_text(ast, input_format="panflute", output_format="native")
        ref = pf.Para(self.ElementType(pf.Str("a"), pf.Space, pf.Str("b")))
        ref_native = convert_text(ref, input_format="panflute", output_format="native")
        assert res == ref_native

    def test_all_emph_together(self):
        ast = deepcopy(self.combined)
        ast.walk(self.to_type)
        ast.walk(self.cancel_repeated_type)
        ast.walk(self.merge_consecutive_type)
        res = convert_text(ast, input_format="panflute", output_format="native")
        ref = pf.Para(pf.Str("a"), pf.Str("b"), pf.Space, self.ElementType(pf.Str("c"), pf.Str("d")))
        ref_native = convert_text(ref, input_format="panflute", output_format="native")
        assert res == ref_native


# works with most but not all of inline elements as well:
# https://github.com/jgm/pandoc-types/blob/master/src/Text/Pandoc/Definition.hs


class TestUnderline(TestEmph):
    ElementType = pf.Underline


class TestStrong(TestEmph):
    ElementType = pf.Strong


class TestStrikeout(TestEmph):
    ElementType = pf.Strikeout


class TestSubscript(TestEmph):
    ElementType = pf.Superscript


class TestSubscript(TestEmph):
    ElementType = pf.Subscript


class TestSmallCaps(TestEmph):
    ElementType = pf.SmallCaps


class TestQuoted(TestEmph):
    ElementType = pf.Quoted


class TestCite(TestEmph):
    ElementType = pf.Cite


class TestLink(TestEmph):
    ElementType = pf.Link


class TestImage(TestEmph):
    ElementType = pf.Image


class TestSpan(TestEmph):
    ElementType = pf.Span
