.PHONY: verify test json-check compile format lint

PYTHON ?= python3

verify: json-check lint compile test

json-check:
	$(PYTHON) -m json.tool data/channels.json >/dev/null

compile:
	$(PYTHON) -m compileall parliament_streams tests

format:
	ruff format parliament_streams tests

lint:
	ruff check parliament_streams tests

test:
	$(PYTHON) -m unittest discover -s tests
