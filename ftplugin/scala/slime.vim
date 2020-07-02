
function! _EscapeText_scala(text)
  if exists('g:slime_scala_ammonite')
    return ["{\n", a:text, "}\n"]
  else
    return [":paste\n", a:text, ""]
  end
endfunction

