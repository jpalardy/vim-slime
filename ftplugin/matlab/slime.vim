" guess correct number of spaces to indent
" (tabs cause 'no completion found' messages)
function! Get_indent_string()
    return repeat(" ", 4)
endfunction

" replace tabs by spaces
function! Tab_to_spaces(text)
    return substitute(a:text, "	", Get_indent_string(), "g")
endfunction


" Check if line is commented out
function! Is_comment(line)
    return (match(a:line, "^[ \t]*%.*") >= 0)
endfunction

" Remove commented out lines
function! Remove_line_comments(lines)
    return filter(copy(a:lines), "!Is_comment(v:val)")
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
function! _EscapeText_matlab(text)
    let l:lines = Lines(Tab_to_spaces(a:text))
    let l:lines = Remove_line_comments(l:lines)
    return Unlines(l:lines)
endfunction
