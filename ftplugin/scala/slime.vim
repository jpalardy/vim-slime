
function! _EscapeText_scala(text)
  if exists('g:slime_scala_ammonite')
    return ["{\n", a:text, "}\n"]
  end
  return [":paste\n", a:text, ""]
endfunction
