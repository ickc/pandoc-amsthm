"""Some utilities, e.g. setup logging."""

from __future__ import annotations

import logging
import os

try:
    from coloredlogs import ColoredFormatter as Formatter
except ImportError:
    from logging import Formatter


def setup_logging(
    name: str = "amsthm",
    level: str = "INFO",
    env_var: str = "AMSTHMLOGLEVEL",
    fmt: str = "%(name)s %(levelname)s %(message)s",
    Handler=logging.StreamHandler,
    Formatter=Formatter,
) -> logging.Logger:
    """Setup logging.

    :param env_var: if not empty, set log level from this environment variable.
    """
    logger = logging.getLogger(name)
    handler = Handler()
    handler.setFormatter(Formatter(fmt))
    logger.addHandler(handler)
    if env_var:
        try:
            logger.setLevel(level=(_level := os.environ.get(env_var, level)))
        except ValueError:
            logger.setLevel(level=level)
            logger.error(
                "%s=%s is not a valid logging level, set to default %s.",
                env_var,
                _level,
                level,
            )
    else:
        logger.setLevel(level=level)
    return logger
