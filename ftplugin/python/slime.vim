
function! _EscapeText_python(text)
  if exists('g:slime_python_ipython') && len(split(a:text,"\n")) > 1
    return "%cpaste\n".a:text."--\n"
  else
    let no_empty_lines = substitute(a:text, '\(^\|\n\)\zs\s*\n\+\ze', "", "g")
    let except_pat = '\(elif\|else\|except\|finally\)\@!'
    let add_eol_pat = '\n\s[^\n]\+\n\zs\ze'.except_pat.'\S'
    return substitute(no_empty_lines, add_eol_pat, "\n", "g")."\n"
  end
endfunction

