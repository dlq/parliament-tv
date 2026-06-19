"""Command-line entry point for parsing saved schedule/EPG responses."""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

from . import SCRAPERS


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(
        prog="python3 -m parliament_streams.scrapers",
        description="Parse saved official schedule/EPG responses with a registered scraper.",
    )
    parser.add_argument("scraper", choices=sorted(SCRAPERS), help="Registered scraper id.")
    parser.add_argument(
        "input",
        nargs="+",
        type=Path,
        help=(
            "Input response file(s). Quebec requires live JSON first and optional upcoming JSON "
            "second; other scrapers use one HTML file."
        ),
    )
    args = parser.parse_args(argv)

    scraper = SCRAPERS[args.scraper]
    inputs = [path.read_text(encoding="utf-8") for path in args.input]

    if args.scraper == "quebec-webdiffusion":
        if len(inputs) > 2:
            parser.error(
                "quebec-webdiffusion accepts one live JSON file and optional upcoming JSON."
            )
        result = scraper.parse(*inputs)
    else:
        if len(inputs) != 1:
            parser.error(f"{args.scraper} expects exactly one input file.")
        result = scraper.parse(inputs[0])

    json.dump(result, sys.stdout, indent=2, sort_keys=True)
    sys.stdout.write("\n")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
