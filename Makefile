################################################################################
# A generic Makefile for handling lua5.3 developpment process.
################################################################################

DEFAULT_LUA = 'lua5.1'

# Use lua5.1 unless another version has been specified on the command line.
# make test LUA=lua5.3
LUA?= $(DEFAULT_LUA)

SRC_DIR = 'navbar'

LOCAL_DIRS  := $(shell find $(SRC_DIR) -type d)
LOCAL_FILES := $(shell find $(SRC_DIR) -name '*.lua' -or -name '*.md' -or -name '*.json' -or -name '*.yaml')

TEST_DIR = 'test'
TEST_FILES_FUNC := $(shell find $(TEST_DIR) -name 'f_*.lua')
TEST_FILES_UNIT := $(shell find $(TEST_DIR) -name 'u_*.lua')

DEST = 'local/micro/plug'

################################################################################
# Rules
################################################################################

help:
	@echo "----------------"
	@echo "Available rules:"
	@echo "----------------"
	@echo
	@echo "clear: 	clear the terminal."
	@echo "clean: 	clean the generated files (doc, etc.)"
	@echo
	@echo "doc: 	build the documentation."
	@echo
	@echo "test: 	run the functional and unit tests (can specify the version of lua to use with LUA=lua5.3, default to lua5.1)"
	@echo
	@echo "push: 	push repository on server with git push and git push --tags."

doc:
	@ldoc -q -p 'micro_navbar' -d doc navbar 2>/dev/null

clean:
	@rm -rf doc/*

clear:
	clear

install: install_link

install_link:
	@mkdir -p $(DEST)
	@for dir  in $(LOCAL_DIRS);  do echo 'mkdir $(DEST)/'$$dir;  mkdir -p $(DEST)/$$dir; done
	@for file in $(LOCAL_FILES); do echo 'ln -s $(DEST)/'$$file; ln -r -s $$file $(DEST)/$$file; done

push:
	git push
	git push --tags

testu:
	@for file in $(TEST_FILES_UNIT); do echo $$file; $(LUA) $$file; done

testf:
	@for file in $(TEST_FILES_FUNC); do echo $$file; $(LUA) $$file; done

test: testf testu

.PHONY: doc