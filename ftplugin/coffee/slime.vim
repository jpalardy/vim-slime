
function! _EscapeText_coffee(text)
  " \x16 is ctrl-v
  return ["\x16", a:text, "\x16"]
endfunction

