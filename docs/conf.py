import sphinx_bootstrap_theme

html_css_files = [
    "https://cdn.jsdelivr.net/gh/ickc/markdown-latex-css/css/_table.min.css",
    "https://cdn.jsdelivr.net/gh/ickc/markdown-latex-css/fonts/fonts.min.css",
]

extensions = [
    "sphinx.ext.autodoc",
    "sphinx.ext.autosummary",
    "sphinx.ext.coverage",
    "sphinx.ext.doctest",
    "sphinx.ext.extlinks",
    "sphinx.ext.ifconfig",
    "sphinx.ext.napoleon",
    "sphinx.ext.todo",
    "sphinx.ext.viewcode",
    "sphinxcontrib.apidoc",
]
source_suffix = ".rst"
master_doc = "index"
project = "amsthm"
year = "2016-2021"
author = "Kolen Cheung"
copyright = f"{year}, {author}"
version = release = "2.0.0"

pygments_style = "solarized-light"
html_theme = "bootstrap"
html_theme_path = sphinx_bootstrap_theme.get_html_theme_path()
html_theme_options = {
    "navbar_links": [
        (
            "GitHub",
            "https://github.com/ickc/pandoc-amsthm/",
            True,
        )
    ],
    "source_link_position": None,
    "bootswatch_theme": "readable",
    "bootstrap_version": "3",
}

html_use_smartypants = True
html_last_updated_fmt = "%b %d, %Y"
html_split_index = False
html_short_title = f"{project}-{version}"

napoleon_use_ivar = True
napoleon_use_rtype = False
napoleon_use_param = False

# math_number_all = True

mathjax_path_lut = {
    "jsdelivr": "https://cdn.jsdelivr.net/npm/mathjax@3/es5/tex-chtml-full.js",
    "unpkg": "https://www.unpkg.com/mathjax@3/es5/tex-chtml-full.js",
    "cloudflare": "https://cdnjs.cloudflare.com/ajax/libs/mathjax/3.2.0/es5/tex-chtml-full.js",
    "githack": "https://rawcdn.githack.com/mathjax/MathJax/3.2.0/es5/tex-chtml-full.js",
    "statically": "https://cdn.statically.io/gh/mathjax/MathJax/3.2.0/es5/tex-chtml-full.js",
}

mathjax_path = mathjax_path_lut["jsdelivr"]

mathjax3_config = {
    "loader": {
        "load": [
            # "[tex]/physics",
            "[tex]/mathtools",
            "[tex]/empheq",
        ]
    },
    "tex": {
        "packages": {
            "[+]": [
                # "physics",
                "mathtools",
                "empheq",
            ],
        },
        "tags": "ams",
    },
}

# sphinxcontrib.apidoc
apidoc_module_dir = "../src/amsthm"
apidoc_separate_modules = True
apidoc_module_first = True
