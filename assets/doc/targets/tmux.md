
### tmux

[Tmux](https://github.com/tmux/tmux) is *not* the default, to use it you will have to add this line to your .vimrc:

    let g:slime_target = "tmux"

Before tmux 2.2, tmux accepted input from STDIN. This doesn't work anymore. To
make it work out without explicit config, the default was changed to use a file
like Screen. By default this file is set to `$HOME/.slime_paste`. The name of
the file used can be configured through a variable:

    let g:slime_paste_file = expand("$HOME/.slime_paste")
    " or maybe...
    let g:slime_paste_file = tempname()

⚠️  This file is not erased by the plugin and will always contain the last thing you sent over.

When you invoke vim-slime for the first time, you will be prompted for more configuration.

tmux socket name or absolute path:

    If you started tmux with the -L or -S flag, use that same socket name or path here.
    If you didn't put anything, the default name is "default".

tmux target pane:

Note that all of these ordinals are 0-indexed by default.

    ":"       means current window, current pane (a reasonable default)
    ":i"      means the ith window, current pane
    ":i.j"    means the ith window, jth pane
    "h:i.j"   means the tmux session where h is the session identifier
              (either session name or number), the ith window and the jth pane
    "%i"      means i refers the pane's unique id
    "{token}" one of tmux's supported special tokens, like "{last}"


You can configure the defaults for these options. If you generally run vim in
a split tmux window with a REPL in the other pane:

    let g:slime_default_config = {"socket_name": get(split($TMUX, ","), 0), "target_pane": ":.2"}

Or more reliably by employing [a special token](http://man.openbsd.org/OpenBSD-current/man1/tmux.1#_last__2) as pane index:

    let g:slime_default_config = {"socket_name": "default", "target_pane": "{last}"}

tmux bracketed-paste

Sometimes REPL are too smart for their own good, e.g. autocompleting a bracket
that should not be autocompleted when pasting code from a file. In this case
it can be useful to rely on bracketed-paste
(https://cirw.in/blog/bracketed-paste). Luckily, tmux knows how to handle
that. See tmux's manual. Setting `g:slime_bracketed_paste` to `1` in your `.vimrc`
enables or disables bracketed-paste. It is disabled by default because it can
create issues with ipython. See
[#265](https://github.com/jpalardy/vim-slime/pull/265).

