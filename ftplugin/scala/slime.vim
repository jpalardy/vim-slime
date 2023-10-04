
function! _EscapeText_scala(text)
  if slime#config#resolve("scala_ammonite", 0)
    return ["{\n", a:text, "}\n"]
  end
  " \x04 is ctrl-d
  return [":paste\n", a:text, "\x04"]
endfunction
