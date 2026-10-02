.PHONY: validate smoke
validate:
	python scripts/validate_blueprints.py
	python -m py_compile python/02_velocity_paga.py
smoke:
	python scripts/validate_blueprints.py
	python python/02_velocity_paga.py --help

