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
	@echo "clean: 	clean the generated files (doc, etc.)"
	@echo
	@echo "doc: 	build the documentation."
	@echo
	@echo "push:    push repository on server with git push and git push --tags."

ldoc:
	@ldoc -q -p 'micro_navbar' -d doc navbar 2>/dev/null

clean:
	@rm -rf doc/*

clear:
	clear

push:
	git push
	git push --tags

testu:
	lua test/u_test.lua
	lua test/u_generic.lua
#	lua test/u_tree.lua

testf:
	lua test/f_test.lua

test: testf testu
