
function! _EscapeText_python(text)
  if exists('g:slime_python_ipython')
    return "%cpaste\n".a:text."--\n"
  else
    let no_empty_lines = substitute(a:text, '\n\s*\ze\n', "", "g")
    return substitute(no_empty_lines, "\n", "", "g")
  end
endfunction

