
Advanced Configuration
----------------------

## Mappings
If you need this, you might as well refer to [the code](https://github.com/jpalardy/vim-slime/blob/master/plugin/slime.vim#L233-L245).
The code is not as complicated as you think. 😄

If you don't want the default key mappings, set:

```vim
let g:slime_no_mappings = 1
```

*before* the plugin is loaded.

If you are using [lazy.nvim](https://github.com/folke/lazy.nvim) as package manager, this can also be done within the `init` function:

```lua
{
    "jpalardy/vim-slime",
    init = function()
        vim.g.slime_no_mappings = 1
    end
}
```

The default mappings are:

```vim
xmap <c-c><c-c> <Plug>SlimeRegionSend
nmap <c-c><c-c> <Plug>SlimeParagraphSend
nmap <c-c>v     <Plug>SlimeConfig
```

### Vim Style Mappings

Example of how to set vim-style mappings:

```vim
"disables default bindings
let g:slime_no_mappings = 1

"send visual selection
xmap <leader>s <Plug>SlimeRegionSend

"send based on motion or text object
nmap <leader>s <Plug>SlimeMotionSend

"send line
nmap <leader>ss <Plug>SlimeLineSend
```

Of course these mappings are just examples; you can set them according to your preference.

## Set a Custom Default Config

If you want `vim-slime` to prefill the prompt answers, you can set a default configuration:

```vim
" screen:
let g:slime_default_config = {"sessionname": "xxx", "windowname": "0"}

" tmux:
let g:slime_default_config = {"socket_name": "default", "target_pane": "1"}
```

If you want `vim-slime` to bypass the prompt and use the specified default configuration options, set the `g:slime_dont_ask_default` option:

```vim
let g:slime_dont_ask_default = 1
```

## Don't Restore Cursor Position

By default, `vim-slime` will try to restore your cursor position after it runs. If you don't want that behavior, unset the `g:slime_preserve_curpos` option:

```vim
let g:slime_preserve_curpos = 0
```

## Send Delimited Cells

If you want to send blocks of code between two delimiters, emulating the cell-like mode of REPL environments like ipython, matlab, etc., you can set the cell delimiter to the `b:slime_cell_delimiter` or `g:slime_cell_delimiter` variable and use the `<Plug>SlimeSendCell` mapping to send the block of code. For example, if you are using ipython you could use the following:

```vim
let g:slime_cell_delimiter = "#%%"
nmap <leader>s <Plug>SlimeSendCell
```

⚠️  it's recommended to use `b:slime_cell_delimiter` and set the variable in `ftplugin` for each relevant filetype.

If you need more advanced cell features, such as syntax highlighting or cell navigation, you might want to have a look at [vim-slime-cells](https://github.com/Klafyvel/vim-slime-cells).


Advanced Configuration: Overrides
---------------------------------

At the end of the day, you might find that `vim-slime` _ALMOST_ does everything
you need, but not quite the way you like it. You might be tempted to fork it,
but the idea of writing and maintaining vimscript is daunting (trust me: I sympathize 😐).

You can override _some_ logic and still benefit from the rest of `vim-slime`.
Here's the mental model you need to understand how things work:

1. you invoke a key binding and `vim-slime` grabs a chunk of text
2. depending on which language you are using (see below), the text might be "transformed" and "massaged" to paste correctly
3. if the config is missing, the user is prompted to fill in the blanks
4. a target-specific function is called to delegate the "send this text to the right target" part
5. the target receives the right text, the right way, and everything works

There is some good news, for step 2, 3, 4, you can override the logic with your
own functions! Put these functions in your `.vimrc` and hijack the part you
need.

You can override any or all (zero to many) of these functions, as needed.

Why is this awesome?

- skip vimscript: delegate to an external script; written in your own preferred language
- optimize for you: treat yourself with just-for-you customizations and hardcoded values
- ultimate power: beyond config and flags, passing a function means you can do anything you want

You might still need some vimscript to glue things together. Leaning on the
`vim-slime` code for examples might get you 90% of what you need. If not, there's
always [Learn Vimscript the Hard Way](https://learnvimscriptthehardway.stevelosh.com/).

If you feel others can benefit from your customizations, open a PR and we'll find a way.


### How to override "language transformations"?

Write a function named `SlimeOverride_EscapeText_#{language}`:

```vim
function SlimeOverride_EscapeText_python(text)
  return system("some-command-line-script", a:text)
endfunction
```

This example code, for Python in this case, pushes the selected text to `some-command-line-script`
through STDIN and returns whatever that script produced through STDOUT.

Contract:
- input is selected text
- output is string or an array of strings (see other `ftplugin` for details)

### How to override "configuration"?

Write a function named `SlimeOverrideConfig`:

```vim
function SlimeOverrideConfig()
  let b:slime_config = {}
  let b:slime_config["key"] = input("key: ", "default value")
endfunction
```

Contract:
- no input, but...
- `b:slime_config` might contain `g:slime_default_config` if it was defined, or be undefined otherwise
- no output but...
- `b:slime_config` expected to contain necessary keys and values used by the target send function (up next)

### How to override "send to target"?

Write a function named `SlimeOverrideSend`:

```vim
function SlimeOverrideSend(config, text)
  echom a:config
  call system("send-to-target --key " . a:config["key"], a:text)
endfunction
```

Contract:
- inputs are config (from config function, above or default) and selected text (post transformation)
- no output but...
- expected to do whatever is needed to send to target, probably a call to `system` but see code for details

