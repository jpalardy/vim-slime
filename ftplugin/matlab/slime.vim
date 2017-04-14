function! _EscapeText_matlab(text)
  if exists('g:slime_matlab_eval')
    let text_escap = substitute(a:text, '''', '''''', 'g')
    let text_split = split(text_escap, "\n")
    let text_quote = map(copy(text_split), '"''" . v:val . "'',..."')
    let text_evals = ['eval([...'] + text_quote + [']);']
    return join(text_evals, "\n")."\n"
  else
    return a:text
  end
endfunction

