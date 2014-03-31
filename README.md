vim-slime
=========

Grab some text and "send" it to a [GNU Screen](http://www.gnu.org/software/screen/) / [tmux](http://tmux.sourceforge.net/) / [whimrepl](https://github.com/malyn/lein-whimrepl) session.

    VIM ---(text)---> screen / tmux / whimrepl

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

Because Screen doesn't accept input from STDIN, a file is used to pipe data
between Vim and Screen. By default this file is set to `$HOME/.slime_paste`.
The name of the file used can be configured through a variable:

    let g:slime_paste_file = "$HOME/.slime_paste"

This file is not erased by the plugin and will always contain the last thing
you sent over. If this is a problem, I recommend you switch to tmux.

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
    "h:i.j" means the tmux session where h is the session identifier (either session name or number), the ith window and the jth pane

By default `STDIN` is used to pass the text to tmux.
If you experience issues with this you may be able to work around them
by configuring slime to use a file instead:

    let g:slime_paste_file = "$HOME/.slime_paste"

This file is not erased by the plugin and will always contain the last thing
you sent over.  If this behavior is undesired, one alternative is to use a temporary file:

    let g:slime_paste_file = tempname()

If you do not want vim-slime to prompt for every buffer, you can set a default configuration

    let g:slime_default_config = {"socket_name": "default", "target_pane": "1"}

If this default config is not appropriate for a given buffer, you can call `:SlimeConfig`
to reset it.

Configuration (whimrepl)
------------------------

whimrepl is also not the default, to use it you will have to add this line to your .vimrc:

    let g:slime_target = "whimrepl"

When you invoke vim-slime for the first time (see below), you will be prompted for more configuration.

whimrepl server name

    This is the name of the whimrepl server that you wish to target.  whimrepl displays that name in its banner every time you start up an instance of whimrepl.

Key Bindings
------------

By default, the current paragraph will be sent. This is equivalent to typing `vip`. If you (visually) select text, that will be sent over:

    C-c, C-c  --- the same as slime

_You can just hold `Ctrl` and double-tap `c`._

There will be a few questions, as to where you want to send your text, but the answers will be remembered. If you need to reconfigure:

    C-c, v    --- mnemonic: "variables"


Haskell
-------

This plugin has support for sending haskell source code to the `ghci`. Syntax differences between `ghci`
are automatically detected and fixed and comments (which aren't allowed in `ghci`) are filtered. Try
sending the following (correct haskell source code) snippet to `ghci`:

    f :: a -> [a]
    f = replicate 3

This translates to the follwing on the `ghci`:

    :{
    let f :: a -> [a]
        f = replicate 3
    :}

because `ghci` expects a `let` in front of a function definition, needs correct indentation and chains multiple lines together
when they are wrapped in a `:{` `:}` block.

All of this is very nice but my workflow sometimes requires that I send the same code to the `ghci` over
and over, so I usually put it in a separate "script" file that holds some testing instructions
so I can send them quickly.

However since some of the syntax is different between the `ghci` and normal haskell
and I write these script files as if I were writing in `ghci`, sometimes the syntax translation would get in 
the way. Eg. I would write a function call to test a certain function and check it's type:

    (++) "This is a: " "TEST"
    :type (++)

and it get translated to:

    :{
    let (++) "This is a: " "TEST"
        :type (++)
    :}

which is not what I wanted obviously.

To get around this, there is another handler that only kicks in if the filetype in vim is set to `haskell.script`.
If you want access to this handler call `set ft=haskell.script` or create a new ftdetect file which does this for you
for a certain file extension. For instance, I have:

    au BufRead,BufNewFile,BufNew *.hss setl ft=haskell.script

in `~/.vim/ftdetect/hss.vim`.


