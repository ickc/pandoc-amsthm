from __future__ import annotations

import re
from collections import defaultdict
from dataclasses import dataclass, field
from functools import cached_property
from typing import TYPE_CHECKING

import panflute as pf
from panflute.containers import ListContainer
from panflute.elements import Space

from .util import setup_logging

if TYPE_CHECKING:
    from typing import Union

    from panflute.elements import Doc, Element

    THM_DEF = list[Union[str, dict[str, str], dict[str, list[str]]]]


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
# the default of `--top-level-division` in pandoc in the simplest case
DEFAULT_PARENT_COUNTER: str = "section"
METADATA_KEY: str = "amsthm"
REF_REGEX = re.compile(r"^\\ref\{(.*)\}$")

logger = setup_logging()


def to_emph(elem: Element, doc: Doc):
    if isinstance(elem, pf.Str):
        return pf.Emph(elem)


def cancel_emph(elem: Element, doc: Doc):
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


@dataclass
class NewTheorem:
    style: str
    env_name: str
    text: str | None = None
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
        if self.text is None:
            logger.debug("Defaulting text to %s", self.env_name)
            self.text = self.env_name
        if (parent_counter := self.parent_counter) is not None and parent_counter not in PARENT_COUNTERS:
            logger.warning(
                "Unsupported parent_coutner %s, setting to default: %s.", parent_counter, DEFAULT_PARENT_COUNTER
            )
        if self.numbered and (parent_counter is None) is (self.shared_counter is None):
            logger.warning(
                "In numbered environment, either parent_counter or shared_counter should be defined, and not both."
                " Dropping shared_counter."
            )
            self.shared_counter = None

    @property
    def latex(self) -> str:
        res = [r"\newtheorem"]
        if not self.numbered:
            res.append(f"*{{{self.env_name}}}{{{self.text}}}")
        elif self.shared_counter is None:
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


@dataclass
class Proof(NewTheorem):
    style: str = "proof"
    env_name: str = "proof"
    text: str | None = "proof"
    parent_counter: str | None = None
    shared_counter: str | None = None
    numbered: bool = False


@dataclass
class DocOptions:
    """Document options.

    :param: counter_depth: can be n=0-6 inclusive.
        n means n+1 numbers shown in non-LaTeX outputs.
        e.g. n=1 means x.y, where x is the heading 1 counter, y is the theorem counter.
        Should be used with parent_counter to match LaTeX and non-LaTeX output.
    """

    theorems: dict[str, NewTheorem] = field(default_factory=dict)
    counter_depth: int = 1

    def __post_init__(self) -> None:
        try:
            self.counter_depth = int(self.counter_depth)
        except ValueError:
            logger.warning("counter_depth must be int, default to 1.")
            self.counter_depth = 1

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

        texts: dict[str, str] = options.get("texts", {})  # type: ignore[assignment, arg-type]
        parent_counter: str = options.get("parent_counter", DEFAULT_PARENT_COUNTER)  # type: ignore[assignment]

        theorems: dict[str, NewTheorem] = {}
        for style in STYLES:
            option: THM_DEF = options.get(style, [])  # type: ignore[assignment]
            for opt in option:
                if isinstance(opt, dict):
                    for key, value in opt.items():
                        # key
                        theorem = NewTheorem(style, key, text=texts.get(key, None), parent_counter=parent_counter)
                        theorems[theorem.class_name] = theorem
                        # value(s)
                        if isinstance(value, list):
                            for v in value:
                                theorem = NewTheorem(style, v, text=texts.get(v, None), shared_counter=key)
                                theorems[theorem.class_name] = theorem
                        else:
                            v = value
                            theorem = NewTheorem(style, v, text=texts.get(v, None), shared_counter=key)
                            theorems[theorem.class_name] = theorem
                else:
                    key = opt
                    theorem = NewTheorem(style, key, text=texts.get(key, None), parent_counter=parent_counter)
                    theorems[theorem.class_name] = theorem
        # proof is predefined in amsthm
        theorems["proof"] = Proof()
        return cls(theorems, counter_depth=options.get("counter_depth", 1))  # type: ignore[arg-type] # will be verified at __post_init__

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


def prepare(doc: Doc):
    doc._amsthm = options = DocOptions.from_doc(doc)
    if doc.format in {"latex", "beamer"}:
        doc.content.insert(0, options.to_panflute)


def amsthm(elem: Element, doc: Doc):
    options: DocOptions = doc._amsthm
    if isinstance(elem, pf.Header):
        if elem.level <= options.counter_depth:
            # Header.level is 1-indexed, while list is 0-indexed
            options.header_counters[elem.level - 1] += 1
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

            res: list[pf.Element] = []
            # theorem header
            ElementType = pf.Strong if theorem.style in {"plain", "definition"} else pf.Emph
            res.append(ElementType(pf.Str(f"{theorem.text} ")))
            if theorem.numbered:
                counter_name = theorem.counter_name
                options.theorem_counters[counter_name] += 1
                theorem_counter = options.theorem_counters[counter_name]
                theorem_number = ".".join([str(i) for i in options.header_counters] + [str(theorem_counter)])
                if id:
                    options.identifiers[id] = theorem_number
                res.append(
                    pf.Strong(pf.Str(theorem_number))
                    if theorem.style in {"plain", "definition"}
                    else pf.Str(theorem_number)
                )

            if info:
                res.append(pf.Str(f" ({info})"))

            res += [ElementType(pf.Str(r".")), pf.Space]

            # theorem body
            if theorem.style == "plain":
                elem.walk(to_emph)
                elem.walk(cancel_emph)
            # TODO: can be improve this?
            for r in reversed(res):
                elem.content[0].content.insert(0, r)
            if theorem.style == "proof":
                elem.content[-1].content.append(pf.RawInline("<span style='float: right'>◻</span>", format="html"))


def process_ref(elem: Element, doc: Doc):
    options: DocOptions = doc._amsthm
    if isinstance(elem, pf.RawInline) and elem.format == "tex":
        text = elem.text
        if matches := REF_REGEX.findall(text):
            if len(matches) != 1:
                logger.warning("Ignoring ref matching in %s: %s", text, matches)
                return None
            match = matches[0]
            if match in options.identifiers:
                return pf.Str(options.identifiers[match])


def amsthm_latex(elem: Element, doc: Doc):
    """when output format is LaTeX, all div is converted into native LaTeX amsthm environments"""
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
                res.append(f"[{info}]")
            if id:
                res.append(f"\\label{{{id}}}")
            res.append(f"\n{div_content}\n\\end{{{theorem.env_name}}}")
            return pf.RawBlock("".join(res), format="latex")
    return None


def action(elem: Element, doc: Doc):
    if doc.format in {"latex", "beamer"}:
        return amsthm_latex(elem, doc)
    else:
        return amsthm(elem, doc)


def post_action(elem: Element, doc: Doc):
    if doc.format not in {"latex", "beamer"}:
        return process_ref(elem, doc)


def finalize(doc: Doc):
    del doc._amsthm


def main(doc: Doc | None = None):
    return pf.run_filters([action, post_action], prepare=prepare, finalize=finalize, doc=doc)
