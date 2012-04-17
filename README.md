
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

Configuration (GNU Screen)
--------------------------

By default, GNU Screen is assumed, you don't have to do anything. If you want
to be explicit, you can add this line to your .vimrc:

    let g:slime_target = "screen"

When you invoke vim-slime for the first time (see below), you will be prompted for more configuration.

screen session name

    This is what you put in the -S flag, or one of the line of "screen -ls".

screen window name

    This is the window number or name, zero-based.

Configuration (tmux)
--------------------

Tmux is *not* the default, to use it you will have to add this line to your .vimrc:

    let g:slime_target = "tmux"

When you invoke vim-slime for the first time (see below), you will be prompted for more configuration.

tmux socket name

    This is what you put in the -L flag, it will be "default" if you didn't put anything.

tmux target pane

    ":" means current window, current pane (a reasonable default)
    ":i" means the ith window, current pane
    ":i.j" means the ith window, jth pane

Key Bindings
------------

    {Visual}<leader>s to send visually selected text.
    <leader>s{motion} to send motion text.
    <leader>ss to send the current line.
