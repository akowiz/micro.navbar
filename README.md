# Micro Navbar Plugin

![Navbar Plugin in Action](assets/micro.navbar.gif)

*Written in Lua* (Notes: micro seems to be using lua-5.1 and not the latest lua version lua-5.3)

Navigation bar (class and functions) for micro editor (strongly influenced by the design of the filemanager plugin for micro).

There are 3 styles defined to display the tree: 'bare', 'ascii' and 'box'
```
* 'bare' style *

v Classes               > Classes
  v TestClass1            > TestClass1
    . __init__            . TestClass2
    . __str__           > Functions
  . TestClass2          > Variables
v Functions
  . TestFunction
v Variables
  . TestVariable


* 'ascii' style *

- Classes               - Classes
  - TestClass1            + TestClass1
  | . __init__            L TestClass2
  | L __str__           + Functions
  L TestClass2          + Variables
- Functions
  L TestFunction
- Variables
  L TestVariable


* 'box' style *

▾ Classes               ▾ Classes
  ├ TestClass1            ╞ TestClass1
  │ ├ __init__            └ TestClass2
  │ └ __str__           ▸ Functions
  └ TestClass2          ▸ Variables
▾ Functions
  └ TestFunction
▾ Variables
  └ TestVariable
```

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

For python, I also recorded the indentation in order to build a proper hierarchy of the python objects.

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


Settings
--------
- openonstart: bool (true or false), set to true to open navbar for supported files when micro is open. Default to false.
- softwrap: bool (true or false), set to true to use wrapping in the treeview window. Default to false.
- persistent: bool (true or false), set to true to have the list of closed nodes be persistent when closing/opening micro. Default to false.
- treestyle: string ('bare', 'ascii', 'box'), the style to use to display the tree. Default to 'bare'.
- treestyle_spacing: int (0, 1, etc.), the number of extra-characters to use for the tree branches. Default to 0.
- treeview_rune_close_all: string (single letter), the key to use in the tree_view to close all nodes. Default to 'c'.
- treeview_rune_goto: string (single letter), the key to use in the tree_view to move the cursor in the main_view to the corresponding item. Default to 'g'.
- treeview_rune_open_all: string (single letter), the key to use in the tree_view to open all nodes. Default to 'o'.
- treeview_rune_toggle: string (single letter), the key to use in the tree_view to toggle a node with children between open and closed. Default to ' ' (space bar).


Known Bugs
----------
- The 'openonstart' setting can be specified on a per-filetype basis, unfortunately, there is a small issue with micro at the moment (https://github.com/zyedidia/micro/issues/1596) that prevent it from working for buffers created after micro has started. It does work for files specified on the command line when micro is started though.


TODO
----
- Clean up the code.
- Provide better mouse support.
- Integrate with a proper parser like tree-sitter to extract the symbols: objects, classes, functions, variables, constants, etc.
