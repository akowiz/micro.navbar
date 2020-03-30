# Micro Navbar Plugin

![Navbar Plugin in Action](assets/micro.navbar.gif)

*Written in Lua* (Notes: micro seems to be using lua-5.1 and not the latest lua version lua-5.3)

Navigation bar (class and functions) for micro editor (strongly influenced by the design of the filemanager plugin for micro).

This repository is for people who wish to contribute to the navbar plugin, using my development tools (Makefile, tests, etc.). It use https://github.com/akowiz/micro.navbar.plugin as a submodule (so you need to run `git submodule update --init --recursive` after clonning this repository to have access to all the plugin files).

If are only interested in the files required to install/run the plugin, please go to https://github.com/akowiz/micro.navbar.plugin and download the latest release or use micro plugin manager (`micro -plugin install navbar`).


Supported Languages
-------------------
For the current version, I am using a line parser with some regular expressions. I am aware such parser has a lot of limitations, but this is good enough for a MVP (minimum viable product) and for my current needs. Ideally we should be using a proper parser such as tree-sitter (someone is working on integrating it with micro for the syntax highlighting, and maybe we coould piggy-back on the effort for this plugin). If you want more langages to be supported at the moment, you need to contribute a basic parser like the one I wrote for the python and lua languages.

- Python: Python is a fairly rigid programming language (through the use of indentation, etc.) and the line parser should do the job in most situations.

- Lua : Lua is a fairly flexible programming language. It supports object oriented programming but not at the language level (meaning there are multiple ways to implement classes). So, I resorted to write a line parser (a bit of a hack) and it should work as long as your write "clean" code (if your code looks more like python actually). It will return poor results (not display all data) if your program looks like the result of a minifier (a program on a single line) or if you use inner functions (functions defines directly inside a table for example).


Supporting other languages
--------------------------
To support a new language, you must provide a new lua module whose name is the filetype you want to add support for. For example to add support for the go language, you need to create a 'go.lua' file in 'navbar/supported'. This modue will have to provide the necessary function to extract the structure of a document written in that language. Follow the best practises for creating a new lua module:
```
local lgg = {} -- the module to add support for the go language.
```

Then you need to import some of the modules from the plugin to have access to a tree/node object and various constants (see lang.lua).

```
local gen  = require('../generic')
local tree = require('../tree')
local lg   = require('../lang')
```

Finally, you need to provide a function `lgg.export_structure(str)` which will take a string as argument (the content of the buffer), and returns a Tree (lg.Node object) of the various objects from the structure.

It is recommended to keep the children of the root for the 'categories' (such as 'classes', 'functions', 'constants', 'variables', etc.). For highly structured language (like python), you will want to set the functions of an object as a child of the object in the tree. For freeforms languages (like lua), you might need to do a bit of gymnastic to group together functions that are part of an object. You will want to extract all functions (including functions defined inside functions if you can), but limit yourself to the variables that have a global scope.

You may parse the buffer any way you want (I used line parser for python and lua), what matters is the tree you generate. When adding a node to a tree, you will need at least 3 pieces of information:
1. the label (usually the name of the item),
2. the kind of the object (found in the module lg),
3. the line the item can be found in the buffer.

If you want to handle objects hierarchy, you may have to record more information (such as indentation, block depth, etc.).  For example, for the python language, we record the indentation because it provides important information on how to build the hierarchy of objects.

For the go language, you would want to generate a tree like:
```
/
    Structures
        Struct1
        Struct2
    Functions
        Functions1
        Functions2
        Functions3
    Variables
        Variable1
        Variable2
```

That's it.


Supported Platforms
-------------------
This plugin has been developped under linux. It should work on most unix/linux derrivative (such as termux on android). It has not been tested on MacOS nor on Windows. Feel free to contribute to support these platforms.


TODO
----
- Clean up the code.
- Provide better mouse support.
- Integrate with a proper parser like tree-sitter to extract the symbols: objects, classes, functions, variables, constants, etc.
