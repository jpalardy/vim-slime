function! _EscapeText_julia(text)
  if match(a:text, "\n") > -1
    return ["begin\n", a:text, "end\n"]
  end
  return a:text
endfunction

