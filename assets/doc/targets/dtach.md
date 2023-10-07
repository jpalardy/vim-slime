
### dtach

[dtach](http://dtach.sourceforge.net/) is *not* the default, to use it you will have to add this line to your `.vimrc`:

```vim
let g:slime_target = "dtach"
```

When you invoke `vim-slime` for the first time, you will be prompted for more configuration.

socket_path:

    The path to the Unix-domain socket that the dtach session is attached to.
    The default is /tmp/slime

