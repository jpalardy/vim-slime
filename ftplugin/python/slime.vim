
function! _EscapeText_python(text)
  if exists('g:slime_python_ipython') && len(split(a:text,"\n")) > 1
    return "%cpaste\n".a:text."--\n"
  else
    let empty_lines_pat = '\(^\|\n\)\zs\(\s*\n\+\)\+'
    let no_empty_lines = substitute(a:text, empty_lines_pat, "", "g")
    let except_pat = '\(elif\|else\|except\|finally\)\@!'
    let add_eol_pat = '\n\s[^\n]\+\n\zs\ze\('.except_pat.'\S\|$\)'
    return substitute(no_empty_lines, add_eol_pat, "\n", "g")
  end
endfunction

