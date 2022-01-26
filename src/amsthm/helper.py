from __future__ import annotations

from logging import getLogger
from typing import TYPE_CHECKING

import panflute as pf
from panflute.tools import convert_text

logger = getLogger(__name__)

if TYPE_CHECKING:
    from typing import TypeVar

    from panflute.elements import Doc, Element

    EmphLike = TypeVar(
        "EmphLike",
        pf.Emph,
        pf.Underline,
        pf.Strong,
        pf.Strikeout,
        pf.Superscript,
        pf.SmallCaps,
        pf.Quoted,
        pf.Cite,
        pf.Link,
        pf.Image,
        pf.Span,
    )


def to_type(
    elem: Element,
    doc: Doc,
    ElementType: type[EmphLike] = pf.Emph,
) -> EmphLike | None:
    """Convert all Str to ElementType.

    This should works for Emph, Strong, SmallCap, etc.
    """
    if isinstance(elem, pf.Str):
        return ElementType(elem)
    else:
        return None


to_emph = to_type


def cancel_repeated_type(
    elem: Element,
    doc: Doc,
    ElementType: type[EmphLike] = pf.Emph,
) -> list[EmphLike] | None:
    """Emulate the behavior of LaTeX that a double emph is cancelled."""
    # this is to make sure nested Emph in any ways would be canceled.
    if isinstance(elem, ElementType):
        res = []
        for e in elem.content:
            # double Emph
            if isinstance(e, ElementType):
                res += e.content
            # single Emph only, keeping Emph...
            else:
                res.append(ElementType(e))
        return res
    else:
        return None


cancel_emph = cancel_repeated_type


def merge_consecutive_type(
    elem: Element,
    doc: Doc,
    ElementType: type[EmphLike] = pf.Emph,
) -> list[EmphLike] | None:
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
            if isinstance(elem_cur, ElementType):
                if isinstance(elem_next, ElementType):
                    merged = list(elem_cur.content) + list(elem_next.content)
                    content = list(content[:i]) + [ElementType(*merged)] + list(content[i + 2 :])
                    mutated = True
                elif isinstance(elem_next, pf.Space):
                    if isinstance(elem_next_next, ElementType):
                        merged = list(elem_cur.content) + [pf.Space] + list(elem_next_next.content)
                        content = list(content[:i]) + [ElementType(*merged)] + list(content[i + 3 :])
                        mutated = True
        if mutated:
            elem.content = content
    return None


merge_emph = merge_consecutive_type


def cite_to_id_mode(elem: pf.Cite) -> tuple[str, str] | None:
    if len(elem.citations) != 1:
        logger.warning("Not only have 1 citations in Cite: %s. Ignoring...", elem)
        return None
    citation: pf.Citation = elem.citations[0]
    id = citation.id
    mode = citation.mode
    return id, mode


def cite_to_ref(elem: pf.Cite, doc: Doc, check_id: dict[str, str] | None = None) -> pf.RawInline | None:
    """Cite to raw LaTeX ref/eqref.

    :param check_id: if provided, transform only if id is in `check_id`

    This maps `[@...]` to `\\eqref{...}` and `@...` to `\\ref{...}`.
    """
    if (
        isinstance(elem, pf.Cite)
        and (temp := cite_to_id_mode(elem)) is not None
        and (check_id is None or (id := temp[0]) in check_id)
    ):
        mode = temp[1]
        # @[...]
        if mode == "NormalCitation":
            return pf.RawInline(f"\\eqref{{{id}}}", format="latex")
        # @...
        elif mode == "AuthorInText":
            return pf.RawInline(f"\\ref{{{id}}}", format="latex")
        else:
            logger.warning("Unknown citation mode %s from Cite: %s. Ignoring...", mode, elem)
            return None
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
