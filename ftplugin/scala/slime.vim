
function! _EscapeText_scala(text)
  return [":paste\n", a:text, ""]
endfunction

