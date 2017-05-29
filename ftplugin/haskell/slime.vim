" Remove '>' on line beginning in literate haskell
function! Remove_initial_gt(lines)
    return map(copy(a:lines), "substitute(v:val, '^>[ \t]*', '', 'g')")
endfunction

function! Is_type_declaration(line)
  let l:isNewType = a:line =~ "newtype"
  let l:isTypeAlias = a:line =~ "type"
  let l:isData = a:line =~ "data"
  return l:isNewType || l:isTypeAlias || l:isData
endfunction

" Prepend certain statements with 'let'
function! Perhaps_prepend_let(lines)
    if len(a:lines) > 0
        let l:lines = a:lines
        let l:line  = l:lines[0]

        " Prepend let if the line is an assignment
        if (l:line =~ "=[^>]" || l:line =~ "::") && !Is_type_declaration(l:line)
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

" indent lines except for first one.
" lines are indented equally, so indentation is preserved.
function! Indent_lines(lines)
    let l:lines = a:lines
    let l:indent = Get_indent_string()
    let l:i = 1
    let l:len = len(l:lines)
    while l:i < l:len
        let l:lines[l:i] = l:indent . l:lines[l:i]
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
    return filter(copy(a:lines), "!Is_comment(v:val)")
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

function! FilterImportLines(lines)
    let l:matches = []
    let l:noMatches = []
    for l:line in a:lines
        if l:line =~ "^import"
            call add(l:matches, l:line)
        else
            call add(l:noMatches, l:line)
        endif
    endfor
    return [l:matches, l:noMatches]
endfunction

" vim slime handler
function! _EscapeText_lhaskell(text)
    let l:text  = Remove_block_comments(a:text)
    let l:lines = Lines(Tab_to_spaces(l:text))
    let l:lines = Remove_initial_gt(l:lines)
    let [l:imports, l:nonImports] = FilterImportLines(l:lines)
    let l:lines = Remove_line_comments(l:nonImports)
    let l:lines = Perhaps_prepend_let(l:lines)
    let l:lines = Indent_lines(l:lines)
    let l:lines = Wrap_if_multi(l:lines)
    return Unlines(l:imports + l:lines)
endfunction

function! _EscapeText_haskell(text)
    let l:text  = Remove_block_comments(a:text)
    let l:lines = Lines(Tab_to_spaces(l:text))
    let [l:imports, l:nonImports] = FilterImportLines(l:lines)
    let l:lines = Remove_line_comments(l:nonImports)
    let l:lines = Perhaps_prepend_let(l:lines)
    let l:lines = Indent_lines(l:lines)
    let l:lines = Wrap_if_multi(l:lines)
    return Unlines(l:imports + l:lines)
endfunction

function! _EscapeText_haskell_script(text)
    let l:text  = Remove_block_comments(a:text)
    let l:lines = Lines(Tab_to_spaces(l:text))
    let l:lines = Remove_line_comments(l:lines)
    return Unlines(l:lines)
endfunction
