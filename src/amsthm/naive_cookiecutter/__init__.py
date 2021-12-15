from __future__ import annotations

import defopt

from .util import setup_logging

__version__: str = "1.2.3"

logger = setup_logging()


def main():
    pass


def cli():
    defopt.run(main)


if __name__ == "__main__":
    cli()
