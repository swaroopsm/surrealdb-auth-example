.PHONY: hello
hello:
	@echo "Hello World!"

.PHONY: init
init:
	sh ./scripts/db/init

.PHONY: import
import:
	sh ./scripts/db/import