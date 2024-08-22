
# tmux

[Tmux](https://github.com/tmux/tmux) is *not* the default, to use it you will have to add this line to your `.vimrc`:


```vim
let g:slime_target = "tmux"
```

## Configuration

### Socket Selection
When you invoke `vim-slime` (attempt to send text or use the `:SlimeConfig` command) for the first time, you will be prompted for more configuration.

tmux socket name or absolute path:

    If you started tmux with the -L or -S flag, use that same socket name or path here.
    If you didn't put anything, the default name is "default".

### Pane Selection

Note that all of these ordinals are 0-indexed by default.

    ":" or ""      means current window, current pane (a reasonable default)
    ":i"           means the ith window, current pane
    ":i.j"         means the ith window, jth pane
    "h:i.j"        means the tmux session where h is the session identifier
                   (either session name or number), the ith window and the jth pane
    "%i"           means i refers the pane's unique id
    "{token}"      one of tmux's supported special tokens, like "{last}"


You can configure the defaults for these options. If you generally run vim in
a split tmux window with a REPL in the other pane:

```vim
let g:slime_default_config = {"socket_name": get(split($TMUX, ","), 0), "target_pane": ":.2"}
```

Or, more reliably, by leveraging [a special token](http://man.openbsd.org/OpenBSD-current/man1/tmux.1#_last__2) as pane index:

```vim
let g:slime_default_config = {"socket_name": "default", "target_pane": "{last}"}
```

### Socket Selection

#### Manual/Prompted Configuration
After selecting the target socket you will be prompted for the target pane.

This prompt supports tabbed completion.  If `b:slime_config` is not set, no initial sugestion for the target pane will be provided and you can press `<Tab>`/`<S-Tab>` (or `<C-N>`/`<C-P>` once suggestions are shown) to go through the possible targets and press `<CR>` to select.  If `b:slime_config` is set to a potentially valid target pane, this input is pre-filled with the current pane-id.  To tab through the other options, delete the suggested pane-id at the prompt and tab through the options as described.

Autocompletion plugins may interfere with the functioning of the autocompletion menu.

#### Menu Prompted Configuration

To be prompted with a numbered menu of all available tmux panes that are valid targets, which the user can select from by inputting a number, or, if the mouse is enabled, clicking on an entry, set `g:slime_menu_config` to a nonzero value. `:` is presented as the zeroth option.

```vim
let g:slime_menu_config=1
```

This works fine with autocompletion plugins enabled.

## bracketed-paste

Some REPLs can interfere with your text pasting. The [bracketed-paste](https://cirw.in/blog/bracketed-paste) mode exists to allow raw pasting.

`tmux` supports bracketed-paste, use:

```vim
let g:slime_bracketed_paste = 1
" or
let b:slime_bracketed_paste = 1
```

(It is disabled by default because it can create issues with ipython; see [#265](https://github.com/jpalardy/vim-slime/pull/265)).

