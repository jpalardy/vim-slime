" vim slime handler
function! _EscapeText_sh(text)
  let l:lines = slime#common#lines(slime#common#tab_to_spaces(a:text))
  return slime#common#unlines(l:lines)
endfunction
