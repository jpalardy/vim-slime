
" add newline to multi-line blocks
" "\n." --> newline with text after
function! _EscapeText_elm(text)
  if match(a:text, "\n.") > -1
    return [a:text, "\n"]
  endif
  return a:text
endfunction

