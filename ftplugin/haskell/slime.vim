let s:not_prefixable_keywords = [ "import", "data", "instance", "class", "{-#" ]

" Prepend certain statements with 'let'
function! Perhaps_prepend_let(lines)
    let l:lines = a:lines
    let l:word  = split(l:lines[0], " ")[0]

    " if first line is prefixable, prefix with let
    " (taken from Cumino code)
    if index(s:not_prefixable_keywords, l:word) < 0
        let l:lines[0] = "let " . l:lines[0]
    endif

    return l:lines
endfunction

" guess correct number of spaces to indent
" (tabs are not allowed)
function! Get_indent_string()
    if &tabstop > 0
        let l:n = &tabstop
    elseif &softtabstop > 0
        let l:n = &softtabstop
    elseif &shiftwidth > 0
        let l:n = &shiftwidth
    else
        let l:n = 4
    endif
    return repeat(" ", l:n)
endfunction

" indent lines except for first one
function! Indent_lines(lines)
    let l:lines = a:lines
    let l:indent = Get_indent_string()
    let l:i = 1
    let l:len = len(l:lines)
    while l:i < l:len
        " only indent if not starting with space
        if l:lines[l:i][0] != " "
            let l:lines[l:i] = l:indent . l:lines[l:i]
        endif
        let l:i += 1
    endwhile
    return l:lines
endfunction

" replace tabs by spaces
function! Tab_to_spaces(text)
    return substitute(a:text, "	", Get_indent_string(), "g")
endfunction

" Wrap in :{ :} if there's more than one line
function! Wrap_if_multi(lines)
    if len(a:lines) > 1
        return [":{"] + a:lines + [":}"]
    else
        return a:lines
    endif
endfunction

" change string into array of lines
function! Lines(text)
    return split(a:text, "\n")
endfunction

" change lines back into text
function! Unlines(lines)
    return join(a:lines, "\n") . "\n"
endfunction

" vim slime handler
function! _EscapeText_haskell(text)
    let l:lines = Lines(Tab_to_spaces(a:text))
    let l:lines = Perhaps_prepend_let(l:lines)
    let l:lines = Indent_lines(l:lines)
    let l:lines = Wrap_if_multi(l:lines)
    return Unlines(l:lines)
endfunction
