
### Python

Sending code to an interactive Python session is tricky business due to
Python's indentation-sensitive nature. Perfectly valid code which executes when
run from a file may fail with a `SyntaxError` when pasted into the CPython
interpreter.

[IPython](http://ipython.org/) has a `%cpaste` "magic function" that allows for
error-free pasting. In order for vim-slime to make use of this feature for
Python buffers, you need to set the corresponding variable in your .vimrc:

```vim
let g:slime_python_ipython = 1
```

Note: if you're using IPython 5, you _need_ to set `g:slime_python_ipython` for
pasting to work correctly.

#### Note for `tmux`, `kitty`, `wezterm`, `zellij` users

If your target supports [bracketed-paste](https://cirw.in/blog/bracketed-paste), that's
a better option than `g:slime_python_ipython`:

```vim
" in .vimrc
let g:slime_bracketed_paste = 1
" or, in ftplugin/python.vim
let b:slime_bracketed_paste = 1
```

This lets your target deal with all the problems with indentation and avoids depending `%cpaste`,
which occassionally causes issues (e.g., [#327](https://github.com/jpalardy/vim-slime/issues/327))

