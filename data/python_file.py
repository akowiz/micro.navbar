#!/usr/bin/env python3
# -*- coding: utf-8 -*-

DEF_TITLE = 'title'
DM_NONE = 0

def combine_data(x, y):
    return x+y

def display_something():

    def inner_function():
        pass

    return ''

thisismoot = 3

class Foo():
    def __init__(self):
        pass

    def __str__(self):
        return ''

    def func_dummy(self, a, b):
        pass

class Bar(Toto):
    class InnerFoo():
        def __init__(self):
            pass

    def func_another(self, c):
        pass

    def __repr__(self):
        return 'Bar()'
