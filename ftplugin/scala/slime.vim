
function! _EscapeText_scala(text)
  if exists('g:slime_scala_ammonite')
    return ["{\n", a:text, "}\n"]
  end
  " \x04 is ctrl-d
  return [":paste\n", a:text, "\x04"]
endfunction
