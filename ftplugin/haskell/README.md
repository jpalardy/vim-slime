
### Haskell

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

