function! _EscapeText_julia(text)
  if exists('g:slime_julia') && len(split(a:text,"\n")) > 1 
    let empty_2_lines_pat = '\(^\|\n\)\zs\(\s*\n\+\)\{2,}'
    let no_empty_2_lines = substitute(a:text, empty_2_lines_pat, "\n", "g")
    if no_empty_2_lines[0:2]=="let" || no_empty_2_lines[0:4]=="begin"
      return no_empty_2_lines
    else
      return ["begin\n", no_empty_2_lines, "end\n"]
    endif
  endif
  return a:text
endfunction
