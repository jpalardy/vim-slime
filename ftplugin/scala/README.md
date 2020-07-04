
### Scala

By default, vim-slime expects to use the base Scala REPL
(or [sbt](https://www.scala-sbt.org/) console).

Scala's [Ammonite REPL](https://ammonite.io) is an improved Scala REPL,
similar to IPython. It does not have a `:paste` command like the default
REPL, but rather wraps multi-line expressions in curly braces.

To use Ammonite with vim-slime, set the following variable in your .vimrc:

    let g:slime_scala_ammonite = 1

Note that although Scala is usually installed on a per-project basis
through tools like sbt, setting `let g:slime_scala_ammonite = 1`
is a global change to your Vim setup.
You will need to unset the variable in your `.vimrc` before starting Vim
if you decide not to use Ammonite for a particular project.
