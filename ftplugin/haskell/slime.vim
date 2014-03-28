let s:not_prefixable_keywords = [ "import", "data", "instance", "class", "{-#" ]

let g:slime_default_config = {"socket_name": "default", "target_pane": "2:0.0"}

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

" indent lines except for first one
" Todo: use indent settings from file
" to check if already indented and indent properly
function! Indent_lines(lines)
    let l:lines = a:lines
    let l:i = 1
    let l:len = len(l:lines)
    while l:i < l:len
        let l:lines[l:i] = "    " . l:lines[l:i]
        let l:i += 1
    endwhile
    return l:lines
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
    let l:lines = Lines(a:text)
    let l:lines = Perhaps_prepend_let(l:lines)
    let l:lines = Indent_lines(l:lines)
    let l:lines = Wrap_if_multi(l:lines)
    return Unlines(l:lines)
endfunction
