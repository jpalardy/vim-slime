function! _EscapeText_matlab(text)
  if exists('g:slime_matlab_eval')
    let text_trimm = substitute(a:text, '\n\s\+', '\n', 'g')
    let text_escap = substitute(text_trimm, '''', '''''', 'g')
    let text_escap = substitute(text_escap, '%', '%%', 'g')
    let text_escap = substitute(text_escap, '\', '\\\', 'g')
    let text_split = split(text_escap, "\n")
    let text_quote = map(copy(text_split), '"''" . v:val . "\\n'',..."')
    let text_print = ['eval(sprintf([...'] + text_quote + [''''']));']
    return join(text_print, "\n")."\n"
  else
    return a:text
  end
endfunction

