
### whimrepl

[whimrepl](https://github.com/malyn/lein-whimrepl) is *not* the default, to use it you will have to add this line to your `.vimrc`:

```vim
let g:slime_target = "whimrepl"
```

When you invoke `vim-slime` for the first time, you will be prompted for more configuration.

whimrepl server name

    This is the name of the whimrepl server that you wish to target.  whimrepl
    displays that name in its banner every time you start up an instance of
    whimrepl.

