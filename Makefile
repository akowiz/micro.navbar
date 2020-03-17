################################################################################
# A generic Makefile for handling lua5.3 developpment process.
################################################################################

DIST = dist

LATEST = $(shell find $(DIST) -type f -name *.whl | sort -V | tail -1)
LATEST_FILE = $(shell basename $(LATEST))

################################################################################
# Rules
################################################################################

help:
	@echo "----------------"
	@echo "Available rules:"
	@echo "----------------"
	@echo
	@echo "clear:   clear the terminal."
	@echo
	@echo "doc: 	build the documentation."
	@echo
	@echo "push:    push repository on server with git push and git push --tags."

ldoc:
	ldoc -q -p 'micro_navbar' -d doc navbar/generic.lua

clear:
	clear

push:
	git push
	git push --tags

testu:
	@cd test; lua u_test.lua

testf:
	@cd test; lua f_test.lua

test: testf testu
