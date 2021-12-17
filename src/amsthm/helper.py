from __future__ import annotations

from typing import TYPE_CHECKING

import panflute as pf
from panflute.tools import convert_text

if TYPE_CHECKING:

    from panflute.elements import Doc, Element


def to_emph(elem: Element, doc: Doc) -> pf.Emph | None:
    if isinstance(elem, pf.Str):
        return pf.Emph(elem)
    else:
        return None


def cancel_emph(elem: Element, doc: Doc) -> list[Element] | None:
    """Emulate the behavior of LaTeX that a double emph is cancelled."""
    # this is to make sure nested Emph in any ways would be canceled.
    if isinstance(elem, pf.Emph):
        res = []
        for e in elem.content:
            # double Emph
            if isinstance(e, pf.Emph):
                res += e.content
            # single Emph only, keeping Emph...
            else:
                res.append(pf.Emph(e))
        return res
    else:
        return None


def merge_emph(elem: Element, doc: Doc) -> list[Element] | None:
    """Merge neighboring Emph with optionally Space between them."""
    if isinstance(elem, pf.Block):
        content = elem.content
        n = len(content)

        mutated = False
        # walk in reverse direction to avoid mutating current location i
        # also start with the 2nd last entry because we're matching 2 or more elements
        for i in range(n - 2, -1, -1):
            elem_cur = content[i]
            # remember that we are mutated content and therefore len(content) changes too
            elem_next = None if i + 1 >= len(content) else content[i + 1]
            elem_next_next = None if i + 2 >= len(content) else content[i + 2]
            if isinstance(elem_cur, pf.Emph):
                if isinstance(elem_next, pf.Emph):
                    merged = list(elem_cur.content) + list(elem_next.content)
                    content = list(content[:i]) + [pf.Emph(*merged)] + list(content[i + 2 :])
                    mutated = True
                elif isinstance(elem_next, pf.Space):
                    if isinstance(elem_next_next, pf.Emph):
                        merged = list(elem_cur.content) + [pf.Space] + list(elem_next_next.content)
                        content = list(content[:i]) + [pf.Emph(*merged)] + list(content[i + 3 :])
                        mutated = True
        if mutated:
            elem.content = content
    return None


def parse_markdown_as_inline(markdown: str) -> list[Element]:
    """Convert markdown string to panflute AST inline elements."""
    ast = convert_text(markdown)
    res: list[Element] = []
    for e in ast:
        if isinstance(e, pf.Para):
            res += list(e.content)
        else:
            res.append(e)
    return res
