let s:not_prefixable_keywords = [ "import", "data", "instance", "class", "{-#", "type", "case", "do", "let", "default", "foreign", "--"]

" Prepend certain statements with 'let'
function! Perhaps_prepend_let(lines)
    if len(a:lines) > 0
        let l:lines = a:lines
        let l:word  = split(l:lines[0], " ")[0]

        " if first line is prefixable, prefix with let
        " (taken from Cumino code)
        if index(s:not_prefixable_keywords, l:word) < 0
            let l:lines[0] = "let " . l:lines[0]
        endif

        return l:lines
    else
        return a:lines
    endif
endfunction

" guess correct number of spaces to indent
" (tabs are not allowed)
function! Get_indent_string()
    return repeat(" ", 4)
endfunction

" indent lines except for first one
function! Indent_lines(lines)
    let l:lines = a:lines
    let l:indent = Get_indent_string()
    let l:i = 1
    let l:len = len(l:lines)
    let l:seen_where = 0
    while l:i < l:len
        " only indent if not starting with space
        let l:has_guard = match(l:lines[l:i], "\\ \\+|") == 0
        let l:has_where = match(l:lines[l:i], "\\ \\+where") == 0
        let l:seen_where = l:seen_where || l:has_where

        if l:lines[l:i][0] != " " || l:has_guard || l:seen_where
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

" Check if line is commented out
function! Is_comment(line)
    return (match(a:line, "^[ \t]*--.*") >= 0)
endfunction

" Remove commented out lines
function! Remove_line_comments(lines)
    let l:i = 0
    let l:len = len(a:lines)
    let l:ret = []
    while l:i < l:len
        if !Is_comment(a:lines[l:i])
            call add(l:ret, a:lines[l:i])
        endif
        let l:i += 1
    endwhile
    return l:ret
endfunction

" remove block comments
function! Remove_block_comments(text)
    return substitute(a:text, "{-.*-}", "", "g")
endfunction

" remove line comments
" todo: fix this! it only removes one occurence whilst it should remove all.
" function! Remove_line_comments(text)
"     return substitute(a:text, "^[ \t]*--[^\n]*\n", "", "g")
" endfunction

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
    let l:text  = Remove_block_comments(a:text)
    let l:lines = Lines(Tab_to_spaces(l:text))
    let l:lines = Remove_line_comments(l:lines)
    let l:lines = Perhaps_prepend_let(l:lines)
    let l:lines = Indent_lines(l:lines)
    let l:lines = Wrap_if_multi(l:lines)
    return Unlines(l:lines)
endfunction

function! _EscapeText_haskell_script(text)
    echo "ok"
    let l:text  = Remove_block_comments(a:text)
    let l:lines = Lines(Tab_to_spaces(l:text))
    let l:lines = Remove_line_comments(l:lines)
    return Unlines(l:lines)
endfunction
