# Micro Navbar Plugin

![Navbar Plugin in Action](assets/micro.navbar.gif)

*Written in Lua* (Notes: micro seems to be using lua-5.1 and not the latest lua version lua-5.3)

Navigation bar (class and functions) for micro editor.

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
- Python: Python is a fairly rigid programming language (use of indentation, etc.) and I wrote a line parser for it that should work in most situations.

- Lua : Lua is a fairly flexible programming language. It supports object oriented programming but not at the language level (meaning there are multiple ways to implement classes). So, I resorted to write a line parser (a bit of a hack) and it should work as long as your write "clean" code (if your code looks more like python actually). It will "break" (not display all data) if your program looks like the result of a minifier (a program on a single line) or if you use inner functions. I needed to support lua for my own development process (so I build the minimum to support my needs).


Supported Platforms
-------------------
This plugin has been developped under linux. It should work on most unix/linux derrivative (such as termux on android). It has not been tested on MacOS nor on Windows. Feel free to contribute to support these platforms.


Settings
--------
- openonstart: bool (true or false), set to true to open when micro is open. Default to false.
- softwrap: bool (true or false), set to true to use wrapping in the treeview window. Default to false.
- persistent: bool (true or false), set to true to have the list of closed nodes be persistent when closing/opening micro.
- treestyle: string ('bare', 'ascii', 'box'), the style to use to display the tree. Default to 'bare'.
- treestyle_spacing: int (0, 1, etc.), the number of extra-characters to use for the tree branch. Default to 0.
- treeview_rune_close_all: string (single letter), the key to use in the tree_view to close all nodes. Default to 'c'.
- treeview_rune_goto: string (single letter), the key to use in the tree_view to move the cursor in the main_view to the corresponding item. Default to 'g'.
- treeview_rune_open_all: string (single letter), the key to use in the tree_view to open all nodes. Default to 'o'.
- treeview_rune_toggle: string (single letter), the key to use in the tree_view to toggle a node with children between open and closed. Default to ' ' (space bar).


Notes
-----
Current implementation should be easy to adapt to any language using fix indentation (like the python language). For other languages, we would need to rely on another mecanism.


BUGS
----


TODO
----
- Better mouse support.
- Write a proper parser to extract objects, classes, functions, variables, constants with depth