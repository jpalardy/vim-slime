
### Haskell

This plugin has support for sending Haskell source code to `ghci`.

#### Sending normal code

To support older GHC versions, code is processed in order to comply with the
syntax rules that are specific to interactive mode. For instance when sending
the following snippet to `ghci`:

    -- make in triplicate
    f :: a -> [a]
    f = replicate 3

This translates to the following:

    :{
    let f :: a -> [a]
        f = replicate 3
    :}

Some of this behavior can be selectively turned off so that what is run is more
faithful to the actual code in your buffer, but requires a recent enough GHC:

* `let g:slime_haskell_ghci_add_let = 0` disables the transformation of
  top-level bindings into a let binding; requires GHC 8.0.1 or later

#### Sending GHCi scripts

All of this is very nice but my workflow sometimes requires that I send the same
code to `ghci` over and over, so I usually put it in a separate "script" file
that holds some testing instructions so I can send them quickly.

However since some of the syntax is different between interactive and normal
Haskell and I write these script files as if I were writing in `ghci`, sometimes
the syntax translation would get in the way. E.g. I would write a function call
to test a certain function and check it's type:

    (++) "This is a: " "TEST"
    :type (++)

and it get translated to:

    :{
    let (++) "This is a: " "TEST"
        :type (++)
    :}

which is not what I wanted obviously.

To get around this, there is another handler that only kicks in if the filetype
in vim is set to `haskell.script`. If you want access to this handler call `set
ft=haskell.script` or create a new ftdetect file which does this for you for a
certain file extension. For instance, I have:

    au BufRead,BufNewFile,BufNew *.hss setl ft=haskell.script

in `~/.vim/ftdetect/hss.vim`.

