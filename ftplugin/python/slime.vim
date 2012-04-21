
function! _EscapeText_python(text)
  let no_empty_lines = substitute(a:text, '\n\s*\ze\n', "", "g")
  return substitute(no_empty_lines, "\n", "", "g")
endfunction

