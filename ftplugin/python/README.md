
### Python

Sending code to an interactive Python session is tricky business due to
Python's indentation-sensitive nature. Perfectly valid code which executes when
run from a file may fail with a `SyntaxError` when pasted into the CPython
interpreter.

[IPython](http://ipython.org/) has a `%cpaste` "magic function" that allows for
error-free pasting. In order for vim-slime to make use of this feature for
Python buffers, you need to set the corresponding variable in your .vimrc:

    let g:slime_python_ipython = 1

Note: if you're using IPython 5, you _need_ to set `g:slime_python_ipython` for
pasting to work correctly.

#### Note for `tmux` users

If you're using `tmux`, it's better to _not_ set `g:slime_python_ipython`, but
instead use [bracketed-paste](https://cirw.in/blog/bracketed-paste) by setting 
either

    let g:slime_bracketed_paste = 1

in your `vimrc` or

    let b:slime_bracketed_paste = 1

in `ftplugin/python.vim`.

This lets `tmux` deal with all the problems with indentation and avoids depending 
`%cpaste`, which occassionally causes issues (e.g., [#327](https://github.com/jpalardy/vim-slime/issues/327))
