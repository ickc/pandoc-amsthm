from __future__ import annotations

import re
from collections import defaultdict
from dataclasses import dataclass, field
from functools import cached_property, partial
from typing import TYPE_CHECKING

import panflute as pf
from panflute.tools import convert_text

from .helper import cancel_emph, cite_to_id_mode, cite_to_ref, merge_emph, parse_markdown_as_inline, to_emph
from .util import setup_logging

if TYPE_CHECKING:
    from typing import Union

    from panflute.elements import Doc, Element

    THM_DEF = list[Union[str, dict[str, str], dict[str, list[str]]]]

__version__: str = "2.0.0"

PARENT_COUNTERS: set[str] = {
    "part",
    "chapter",
    "section",
    "subsection",
    "subsubsection",
    "paragraph",
    "subparagraph",
}
STYLES: tuple[str, ...] = ("plain", "definition", "remark")
METADATA_KEY: str = "amsthm"
REF_REGEX = re.compile(r"^\\(ref|eqref)\{(.*)\}$")
LATEX_LIKE: set[str] = {"latex", "beamer"}
PLAIN_OR_DEF: set[str] = {"plain", "definition"}
COUNTER_DEPTH_DEFAULT: int = 0

logger = setup_logging()


def parse_info(info: str | None) -> list[Element]:
    """Convert theorem info to panflute AST inline elements."""
    return [pf.Str(r"(")] + parse_markdown_as_inline(info) + [pf.Str(r")")] if info else []


@dataclass
class NewTheorem:
    style: str
    env_name: str
    text: str = ""
    parent_counter: str | None = None
    shared_counter: str | None = None
    numbered: bool = True
    """A LaTeX amsthm new theorem.

    :param parent_counter: for LaTeX output, controlling the number of numbers in a theorem.
        Should be used with counter_depth to match LaTeX and non-LaTeX output.
    """

    def __post_init__(self) -> None:
        if self.env_name.endswith("*"):
            self.env_name = self.env_name[:-1]
            self.numbered = False
        if not self.text:
            logger.debug("Defaulting text to %s", self.env_name)
            self.text = self.env_name
        if (parent_counter := self.parent_counter) is not None and parent_counter not in PARENT_COUNTERS:
            logger.warning("Unsupported parent_counter %s, ignoring.", parent_counter)
        if self.numbered and parent_counter is not None and self.shared_counter is not None:
            logger.warning("Dropping shared_counter as parent_counter is defined.")
            self.shared_counter = None

    @property
    def latex(self) -> str:
        res = [r"\newtheorem"]
        if not self.numbered:
            res.append(f"*{{{self.env_name}}}{{{self.text}}}")
        elif self.shared_counter is None:
            if self.parent_counter is None:
                res.append(f"{{{self.env_name}}}{{{self.text}}}")
            else:
                res.append(f"{{{self.env_name}}}{{{self.text}}}[{self.parent_counter}]")
        else:
            res.append(f"{{{self.env_name}}}[{self.shared_counter}]{{{self.text}}}")
        return "".join(res)

    @property
    def class_name(self) -> str:
        """Name in pandoc div classes.

        It cannot have space.
        """
        return self.env_name.replace(" ", "_")

    @property
    def counter_name(self) -> str:
        return self.env_name if self.shared_counter is None else self.shared_counter

    def to_panflute_theorem_header(
        self,
        options: DocOptions,
        id: str | None,
        info: str | None,
    ) -> list[pf.Element]:
        """Return a theorem header as panflute AST.

        This mutates `options.theorem_counters`, `options.identifiers` in-place.
        """
        TextType: type[Element]
        text = self.text

        # text and number separated by Space

        NumberType: type[Element]
        theorem_number: str | None
        if self.numbered:
            counter_name = self.counter_name
            options.theorem_counters[counter_name] += 1
            theorem_counter = options.theorem_counters[counter_name]
            theorem_number = ".".join([str(i) for i in options.header_counters] + [str(theorem_counter)])
            if id:
                options.identifiers[id] = theorem_number
        else:
            theorem_number = None

        # no additional styling here
        info_list = parse_info(info)

        # append TextType of ".", Space

        # cases: PLAIN_OR_DEF, theorem_number, info_list
        if self.style in PLAIN_OR_DEF:
            TextType = pf.Strong
            NumberType = pf.Strong
        else:
            TextType = pf.Emph
            NumberType = pf.Str
        # We are normalizing the Emph/Strong boundary manually by having 6 cases
        if theorem_number is None:
            if info_list:
                res = [TextType(pf.Str(text)), pf.Space] + info_list + [TextType(pf.Str(".")), pf.Space]
            else:
                res = [TextType(pf.Str(f"{text}.")), pf.Space]
        else:
            if TextType is NumberType:
                if info_list:
                    res = (
                        [TextType(pf.Str(f"{text} {theorem_number}")), pf.Space]
                        + info_list
                        + [TextType(pf.Str(".")), pf.Space]
                    )
                else:
                    res = [TextType(pf.Str(f"{text} {theorem_number}.")), pf.Space]
            else:
                if info_list:
                    res = (
                        [TextType(pf.Str(text)), pf.Space, pf.Str(theorem_number), pf.Space]
                        + info_list
                        + [TextType(pf.Str(".")), pf.Space]
                    )
                else:
                    res = [
                        TextType(pf.Str(text)),
                        pf.Space,
                        pf.Str(theorem_number),
                        TextType(pf.Str(".")),
                        pf.Space,
                    ]
        return res


@dataclass
class Proof(NewTheorem):
    style: str = "proof"
    env_name: str = "proof"
    text: str = "proof"
    parent_counter: str | None = None
    shared_counter: str | None = None
    numbered: bool = False

    def to_panflute_theorem_header(
        self,
        options: DocOptions,
        id: str | None,
        info: str | None,
    ) -> list[pf.Element]:
        """Return a theorem header as panflute AST."""
        if info is None:
            return [pf.Emph(pf.Str("Proof.")), pf.Space]
        else:
            # put it into a Para then walk
            ast = parse_markdown_as_inline(info)
            info_list = pf.Para(*ast)
            info_list.walk(to_emph)
            info_list.walk(cancel_emph)
            info_list.walk(merge_emph)
            return list(info_list.content) + [pf.Emph(pf.Str(".")), pf.Space]


@dataclass
class DocOptions:
    """Document options.

    :param: counter_depth: can be n=0-6 inclusive.
        n means n+1 numbers shown in non-LaTeX outputs.
        e.g. n=1 means x.y, where x is the heading 1 counter, y is the theorem counter.
        Should be used with parent_counter to match LaTeX and non-LaTeX output.
    """

    theorems: dict[str, NewTheorem] = field(default_factory=dict)
    counter_depth: int = COUNTER_DEPTH_DEFAULT
    counter_ignore_headings: set[str] = field(default_factory=set)

    def __post_init__(self) -> None:
        try:
            self.counter_depth = int(self.counter_depth)
        except ValueError:
            logger.warning("counter_depth must be int, default to 1.")
            self.counter_depth = COUNTER_DEPTH_DEFAULT

        # initial count is zero
        # should be += 1 before using
        self.header_counters: list[int] = [0] * self.counter_depth
        self.reset_theorem_counters()
        # from identifiers to numbers
        self.identifiers: dict[str, str] = {}

    def reset_theorem_counters(self) -> None:
        self.theorem_counters: dict[str, int] = defaultdict(int)

    @cached_property
    def theorems_set(self) -> set[str]:
        return set(self.theorems)

    @classmethod
    def from_doc(
        cls,
        doc: Doc,
    ) -> DocOptions:
        options: dict[
            str,
            dict[str, str | dict[str, str] | THM_DEF],
        ] = doc.get_metadata(METADATA_KEY, {})

        name_to_text: dict[str, str] = options.get("name_to_text", {})  # type: ignore[assignment, arg-type]
        parent_counter: str = options.get("parent_counter", None)  # type: ignore[assignment, arg-type]

        theorems: dict[str, NewTheorem] = {}
        for style in STYLES:
            option: THM_DEF = options.get(style, [])  # type: ignore[assignment]
            for opt in option:
                if isinstance(opt, dict):
                    for key, value in opt.items():
                        # key
                        theorem = NewTheorem(style, key, text=name_to_text.get(key, ""), parent_counter=parent_counter)
                        theorems[theorem.class_name] = theorem
                        # value(s)
                        if isinstance(value, list):
                            for v in value:
                                theorem = NewTheorem(style, v, text=name_to_text.get(v, ""), shared_counter=key)
                                theorems[theorem.class_name] = theorem
                        else:
                            v = value
                            theorem = NewTheorem(style, v, text=name_to_text.get(v, ""), shared_counter=key)
                            theorems[theorem.class_name] = theorem
                else:
                    key = opt
                    theorem = NewTheorem(style, key, text=name_to_text.get(key, ""), parent_counter=parent_counter)
                    theorems[theorem.class_name] = theorem
        # proof is predefined in amsthm
        theorems["proof"] = Proof()
        return cls(
            theorems,
            counter_depth=options.get("counter_depth", COUNTER_DEPTH_DEFAULT),  # type: ignore[arg-type] # will be verified at __post_init__
            counter_ignore_headings=set(options.get("counter_ignore_headings", set())),
        )

    @property
    def latex(self) -> str:
        cur_style: str = ""
        res: list[str] = []
        for theorem in self.theorems.values():
            # proof is predefined in amsthm
            if not isinstance(theorem, Proof):
                if theorem.style != cur_style:
                    cur_style = theorem.style
                    res.append(f"\\theoremstyle{{{cur_style}}}")
                res.append(theorem.latex)
        return "\n".join(res)

    @property
    def to_panflute(self) -> pf.RawBlock:
        return pf.RawBlock(self.latex, format="latex")


def prepare(doc: Doc) -> None:
    doc._amsthm = options = DocOptions.from_doc(doc)
    if doc.format in LATEX_LIKE:
        doc.content.insert(0, options.to_panflute)


def amsthm(elem: Element, doc: Doc) -> None:
    """General amsthm transformation working for all document types.

    Essentially we replicate LaTeX amsthm behavior in this filter.
    """
    options: DocOptions = doc._amsthm
    if isinstance(elem, pf.Header):
        if elem.level <= options.counter_depth:
            header_string = None
            if (counter_ignore_headings := options.counter_ignore_headings) and (
                header_string := pf.stringify(elem)
            ) in counter_ignore_headings:
                logger.debug("Ignoring header %s in header_counters as it is in counter_ignore_headings", header_string)
            else:
                # Header.level is 1-indexed, while list is 0-indexed
                options.header_counters[elem.level - 1] += 1
                # reset deeper levels
                for i in range(elem.level, options.counter_depth):
                    options.header_counters[i] = 0
                logger.debug(
                    "Header encounter: %s, current counter: %s", header_string or elem, options.header_counters
                )
                options.reset_theorem_counters()
    elif isinstance(elem, pf.Div):
        environments: set[str] = options.theorems_set.intersection(elem.classes)
        if environments:
            if len(environments) != 1:
                logger.warning("Multiple environments found: %s", environments)
                return None
            environment = environments.pop()
            theorem = options.theorems[environment]

            info = elem.attributes.get("info", None)
            id = elem.identifier

            res = theorem.to_panflute_theorem_header(options, id, info)

            # theorem body
            if theorem.style == "plain":
                elem.walk(to_emph)
                elem.walk(cancel_emph)
                elem.walk(merge_emph)
            try:
                # insert in the beginning of the first block element
                for r in reversed(res):
                    elem.content[0].content.insert(0, r)
            except AttributeError:
                # if fail, insert a Para before content
                elem.content.insert(0, pf.Para(*res))
            r = pf.RawInline("<span style='float: right'>◻</span>", format="html")
            try:
                # insert in the end of the last block element
                if theorem.style == "proof":
                    elem.content[-1].content.append(r)
            except AttributeError:
                # if fail, append a Para
                elem.content.append(pf.Para(r))


def resolve_ref(elem: Element, doc: Doc) -> pf.Str | None:
    """Resolve references to theorem numbers.

    Consider this as post-process ref for general output formats.
    """
    options: DocOptions = doc._amsthm
    # from [@...] to number
    if isinstance(elem, pf.Cite):
        if (temp := cite_to_id_mode(elem)) is not None and (id := temp[0]) in options.identifiers:
            mode = temp[1]
            # @[...]
            if mode == "NormalCitation":
                return pf.Str(f"({options.identifiers[id]})")
            # @...
            elif mode == "AuthorInText":
                return pf.Str(options.identifiers[id])
            else:
                logger.warning("Unknown citation mode %s from Cite: %s. Ignoring...", mode, elem)
                return None

    # from \ref{...} to number
    elif isinstance(elem, pf.RawInline) and elem.format == "tex":
        text = elem.text
        if matches := REF_REGEX.findall(text):
            if len(matches) != 1:
                logger.warning("Ignoring ref matching in %s: %s", text, matches)
                return None
            ref_type, id = matches[0]
            if id in options.identifiers:
                if ref_type == "eqref":
                    return pf.Str(f"({options.identifiers[id]})")
                else:
                    return pf.Str(options.identifiers[id])
    return None


def collect_ref_id(elem: Element, doc: Doc) -> None:
    """Only collect all amsthm environment id.

    This should be used before the `amsthm_latex` filter.
    This is done in 2 passes as the id may be cited/referenced earlier than definition.
    Consider this as pre-process of ref for LaTeX output.

    `options.identifiers` modified in-place.
    """
    # check if it is a Div, and the class is an amsthm environment
    options: DocOptions = doc._amsthm
    environments: set[str]
    if isinstance(elem, pf.Div) and (environments := options.theorems_set.intersection(elem.classes)):
        if len(environments) != 1:
            logger.warning("Multiple environments found: %s", environments)
            return None
        if id := elem.identifier:
            # in LaTeX output, we only need to keep a reference of the id
            # the numbering (value of this dict) is handled by LaTeX
            options.identifiers[id] = ""
    return None


def amsthm_latex(elem: Element, doc: Doc) -> pf.RawBlock | None:
    """Transform amsthm defintion to LaTeX package specifications."""
    # check if it is a Div, and the class is an amsthm environment
    options: DocOptions = doc._amsthm
    if isinstance(elem, pf.Div):
        environments: set[str] = options.theorems_set.intersection(elem.classes)
        if environments:
            if len(environments) != 1:
                logger.warning("Multiple environments found: %s", environments)
                return None
            environment = environments.pop()
            theorem = options.theorems[environment]
            div_content = pf.convert_text(elem, input_format="panflute", output_format="latex")
            info = elem.attributes.get("info", None)
            id = elem.identifier
            res = [f"\\begin{{{theorem.env_name}}}"]
            if info:
                # wrap in Para for walk
                ast = pf.Para(*parse_markdown_as_inline(info))
                ast.walk(partial(cite_to_ref, check_id=options.identifiers))
                ast = convert_text(ast, input_format="panflute", output_format="latex").strip()
                res += [f"[{ast}]"]
            if id:
                res.append(f"\\label{{{id}}}")
            res.append(f"\n{div_content}\n\\end{{{theorem.env_name}}}")
            return pf.RawBlock("".join(res), format="latex")
    # check if pf.Cite is done inside cite_to_ref
    else:
        return cite_to_ref(elem, doc, options.identifiers)
    return None


def action1(elem: Element, doc: Doc) -> pf.RawBlock | None:
    if doc.format in LATEX_LIKE:
        collect_ref_id(elem, doc)
    else:
        amsthm(elem, doc)
    return None


def action2(elem: Element, doc: Doc) -> pf.Str | pf.RawInline | None:
    if doc.format in LATEX_LIKE:
        return amsthm_latex(elem, doc)
    else:
        return resolve_ref(elem, doc)


def finalize(doc: Doc) -> None:
    del doc._amsthm


def main(doc: Doc | None = None) -> None:
    return pf.run_filters(
        (action1, action2),
        prepare=prepare,
        finalize=finalize,
        doc=doc,
    )
