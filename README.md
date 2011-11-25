
vim-slime
=========

Grab some text and "send" it to a [GNU Screen](http://www.gnu.org/software/screen/) / [tmux](http://tmux.sourceforge.net/) session.

    VIM ---(text)---> screen / tmux

Presumably, your screen contains something interesting like, say, a Clojure [REPL](http://en.wikipedia.org/wiki/REPL). But if it can
receive typed text, it can receive it from vim-slime.

The reason you're doing this? Because you want the benefits of a REPL and the benefits of using Vim (familiar environment, syntax highlighting, persistence ...).

Read the [blog post](http://technotales.wordpress.com/2007/10/03/like-slime-for-vim/).

Installation
------------

I recommend installing [pathogen.vim](https://github.com/tpope/vim-pathogen), and
then simply copy and paste:

    cd ~/.vim/bundle
    git clone git://github.com/jpalardy/vim-slime.git

If you like it the hard way, copy plugin/slime.vim from this repo into ~/.vim/plugin.

Configuration
-------------

By default, GNU Screen is assumed. It is equivalent to:

    let g:slime_target = "screen"

If you would rather use tmux, use:

    let g:slime_target = "tmux"

Key Bindings
------------

By default, the current paragraph will be sent. This is equivalent to typing *vip*. If you (visually) select text, that will be sent over:

    C-c, C-c  --- the same as slime

There will be a few questions, as to where you want to send your text, and the answers will be remembered. If you need to reconfigure:

    C-c, v    --- mnemonic: "variables"

