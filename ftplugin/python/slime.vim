
function! _EscapeText_python(text)
  if exists('g:slime_python_ipython')
    return "%cpaste\n".a:text."--\n"
  else
    let no_empty_lines = substitute(a:text, '\n\s*\ze\n', "", "g")

    "" add empty lines between definitions (functions, classes...)
    let some_empty_lines = substitute(no_empty_lines, '\n\zs\ze\S', "\n", "g")
    "" also add an empty line to the end, to end definitions
    let some_empty_lines .= "\n"

    return substitute(some_empty_lines, "\n", "", "g")
  end
endfunction

