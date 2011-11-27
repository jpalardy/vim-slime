function! _EscapeText_python(text)
  return substitute(a:text, "\n", "", "g")
endfunction
