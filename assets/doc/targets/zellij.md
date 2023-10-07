
### Zellij

[Zellij](https://zellij.dev/) is *not* the default, to use it you will have to add this line to your `.vimrc`:

```vim
let g:slime_target = "zellij"
```

When you invoke `vim-slime` for the first time, you will be prompted for more configuration.

Zellij session id

    This is the id of the zellij session that you wish to target,
    the default value is "current" meaning the session containing the vim pane.
    See e.g. the value of "zellij list-sessions" in the target window to figure out
    specific session names.

Zellij relative pane

    "current" for the currently active pane

    "up"/"down"/"right"/"left" for the pane in that direction relative to the location of
    the active pane

You can configure the defaults for these options. If you generally run vim in
a split zellij window with a REPL to the right it could look like this:

```vim
let g:slime_default_config = {"session_id": "current", "relative_pane": "right"}
```

