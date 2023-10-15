
### wezterm

[wezterm](https://wezfurlong.org/wezterm/index.html) is *not* the default, to use it you will have to add this line to your `.vimrc`:

```vim
let g:slime_target = "wezterm"
```

When you invoke `vim-slime` for the first time, you will be prompted for more configuration.

wezterm pane id

    This is the id of the wezterm pane that you wish to target.
    See e.g. the value of $WEZTERM_PANE in the target pane.

wezterm pane direction

    If you want the id of the pane in a relative direction to the default,
    see `wezterm cli get-pane-direction --help` for possible values.

You can configure the defaults for these options. If you generally run vim in
a split wezterm window with a REPL to the right it could look like this:

```vim
let g:slime_default_config = {"pane_direction": "right"}
```

### bracketed-paste

Some REPLs can interfere with your text pasting. The [bracketed-paste](https://cirw.in/blog/bracketed-paste) mode exists to allow raw pasting.

`wezterm` supports bracketed-paste, use:

```vim
let g:slime_bracketed_paste = 1
" or
let b:slime_bracketed_paste = 1
```

(It is disabled by default because it can create issues with ipython; see [#265](https://github.com/jpalardy/vim-slime/pull/265)).

