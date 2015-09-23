function! _EscapeText_sml(text)
    let trimmed = substitute(a:text, '\_s*$', '', '')
    if match(trimmed, ';\n*$') > -1
        return [trimmed, "\n"]
    else
        return [trimmed, ";\n"]
    endif
endfunction
