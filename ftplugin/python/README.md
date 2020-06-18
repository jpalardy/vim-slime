
### Python

Sending code to an interactive Python session is tricky business due to
Python's indentation-sensitive nature. Perfectly valid code which executes when
run from a file may fail with a `SyntaxError` when pasted into the CPython
interpreter.

[IPython](http://ipython.org/) has a `%cpaste` "magic function" that allows for
error-free pasting. In order for vim-slime to make use of this feature for
Python buffers, you need to set the corresponding variable in your .vimrc:
```
    let g:slime_python_ipython = 1
```
Note: if you're using IPython 5, you _need_ to set `g:slime_python_ipython` for
pasting to work correctly. [Jupyter Console](https://jupyter-console.readthedocs.io/en/latest/)
lacks %paste or %cpaste, so IPython should be used instead
(see [jupyter/jupyter-console#20](https://github.com/jupyter/jupyter_console/issues/20)).

[Jupyter QTConsole](https://qtconsole.readthedocs.io/en/stable/) has a quirk
where newline characters are not read when pasting. In order for vim-silme to
send carriage returns instead of newlines for QTConsole, set the following
variable in your .vimrc:
```
    let g:slime_python_qtconsole = 1
```
