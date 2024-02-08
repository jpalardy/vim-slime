vim-slime
=========

Demo
------------

![vim-slime session with R](assets/vim-slime.gif)


What is vim-slime?
------------------

What is [SLIME](https://en.wikipedia.org/wiki/SLIME)?

    SLIME is an Emacs plugin to turn Emacs into a Lisp IDE. You can type text
    in a file, send it to a live REPL, and avoid having to reload all your code
    every time you make a change.

So, what is `vim-slime`?

    vim-slime is a humble attempt at getting _some_ of the SLIME features into Vim.
    It works with any REPL and isn't tied to Lisp.

Grab some text and send it to a [target](#targets):

![vim-slime sends text to a REPL through a target](assets/vim-slime-model.png)

The target contains a [REPL](http://en.wikipedia.org/wiki/REPL), maybe Clojure, R or python. If you can type text into it, `vim-slime` can send text to it.

Why do this? Because you want the benefits of a REPL (instant feedback, no need to reload ...) and the benefits of using Vim (familiar environment, syntax highlighting, persistence ...).

More details in the [blog post](http://technotales.wordpress.com/2007/10/03/like-slime-for-vim/).

Targets
-------

Configure `vim-slime` for your desired target:

```vim
" for all buffers
let g:slime_target = "tmux"

" and/or as a buffer-level override
let b:slime_target = "wezterm"

" if not explicitly configured, it defaults to `screen`
```

Many targets are supported, check their documentation for details:

- [conemu](assets/doc/targets/conemu.md)
- [dtach](assets/doc/targets/dtach.md)
- [kitty](assets/doc/targets/kitty.md)
- [neovim](assets/doc/targets/neovim.md)
- [screen](assets/doc/targets/screen.md) — _default_
- [tmux](assets/doc/targets/tmux.md)
- [vimterminal](assets/doc/targets/vimterminal.md)
- [wezterm](assets/doc/targets/wezterm.md)
- [whimrepl](assets/doc/targets/whimrepl.md)
- [x11](assets/doc/targets/x11.md)
- [zellij](assets/doc/targets/zellij.md)

Installation
------------

Use your favorite package manager, or use Vim's built-in package support (since Vim 7.4.1528):

    mkdir -p ~/.vim/pack/plugins/start
    cd ~/.vim/pack/plugins/start
    git clone https://github.com/jpalardy/vim-slime.git

You can [try vim-slime in Docker](https://blog.jpalardy.com/posts/trying-vim-slime-in-docker/) before committing to anything else.

Usage
-------------

Put your cursor over the text you want to send and type:

<kbd>ctrl-c</kbd> <kbd>ctrl-c</kbd> _--- the same as slime_

_(You can just hold `ctrl` and double-tap `c`.)_

The current paragraph — what would be selected if you typed `vip` — is automatically selected.

To control exactly what is sent, you can manually select text before calling `vim-slime`.

## Vim Style Mappings

To use vim-style mappings, such as `operator+motion` or `operator+text object` see the appropriate [section of the advanced configuration documentation](assets/doc/advanced.md#vim-style-mappings).

Config prompt
--------------

`vim-slime` needs to know where to send your text, it will prompt you.
It will remember your answers and won't prompt you again.

If you want to reconfigure, type:

<kbd>ctrl-c</kbd> <kbd>v</kbd> _--- mnemonic: "variables"_

or call:

    :SlimeConfig

Language Support
----------------

`vim-slime` _might_ have to modify its behavior according to the language or REPL
you want to use.

Many languages are supported without modifications, while [others](ftplugin)
might tweak the text without explicit configuration:

  * [coffee-script](ftplugin/coffee/slime.vim)
  * [elm](ftplugin/elm/slime.vim)
  * [fsharp](ftplugin/fsharp/slime.vim)
  * [haskell](ftplugin/haskell/slime.vim) / [lhaskell](ftplugin/haskell/slime.vim) -- [README](ftplugin/haskell)
  * [matlab](ftplugin/matlab/slime.vim)
  * [ocaml](ftplugin/ocaml/slime.vim)
  * [python](ftplugin/python/slime.vim) / [ipython](ftplugin/python/slime.vim) -- [README](ftplugin/python)
  * [scala](ftplugin/scala/slime.vim) / [ammonite](ftplugin/scala/slime.vim) -- [README](ftplugin/scala)
  * [sml](ftplugin/sml/slime.vim)
  * [stata](ftplugin/stata/slime.vim)

Advanced Configuration
----------------------

If plain `vim-slime` isn't doing _exactly_ what you want, have a look
at [advanced configuration](assets/doc/advanced.md).

