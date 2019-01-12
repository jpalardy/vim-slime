" GHC before 8.0.1 does not support top-level bindings
if !exists('g:slime_haskell_ghci_add_let')
    let g:slime_haskell_ghci_add_let = 1
endif

" Remove '>' on line beginning in literate haskell
function! s:Remove_initial_gt(lines)
    return map(copy(a:lines), "substitute(v:val, '^>[ \t]*', '', 'g')")
endfunction

function! s:Is_type_declaration(line)
  let l:isNewType = a:line =~ "newtype"
  let l:isTypeAlias = a:line =~ "type"
  let l:isData = a:line =~ "data"
  return l:isNewType || l:isTypeAlias || l:isData
endfunction

" Prepend certain statements with 'let'
function! s:Perhaps_prepend_let(lines)
    if len(a:lines) > 0
        let l:lines = a:lines
        let l:line  = l:lines[0]

        " Prepend let if the line is an assignment
        if (l:line =~ "=[^>]" || l:line =~ "::") && !s:Is_type_declaration(l:line)
            let l:lines[0] = "let " . l:lines[0]
        endif

        return l:lines
    else
        return a:lines
    endif
endfunction

" indent lines except for first one.
" lines are indented equally, so indentation is preserved.
function! s:Indent_lines(lines)
    let l:lines = a:lines
    let l:indent = slime#common#get_indent_string()
    let l:i = 1
    let l:len = len(l:lines)
    while l:i < l:len
        let l:lines[l:i] = l:indent . l:lines[l:i]
        let l:i += 1
    endwhile
    return l:lines
endfunction

" Check if line is commented out
function! s:Is_comment(line)
    return (match(a:line, "^[ \t]*--.*") >= 0)
endfunction

" Remove commented out lines
function! s:Remove_line_comments(lines)
    return filter(copy(a:lines), "!s:Is_comment(v:val)")
endfunction

" remove block comments
function! s:Remove_block_comments(text)
    return substitute(a:text, "{-.*-}", "", "g")
endfunction

" remove line comments
" todo: fix this! it only removes one occurence whilst it should remove all.
" function! s:Remove_line_comments(text)
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

function! s:FilterImportLines(lines)
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
    let l:text  = s:Remove_block_comments(a:text)
    let l:lines = slime#common#lines(slime#common#tab_to_spaces(l:text))
    let l:lines = s:Remove_initial_gt(l:lines)
    let [l:imports, l:nonImports] = s:FilterImportLines(l:lines)
    let l:lines = s:Remove_line_comments(l:nonImports)

    if g:slime_haskell_ghci_add_let
        let l:lines = s:Perhaps_prepend_let(l:lines)
        let l:lines = s:Indent_lines(l:lines)
    endif

    let l:lines = Wrap_if_multi(l:lines)
    return slime#common#unlines(l:imports + l:lines)
endfunction

function! _EscapeText_haskell(text)
    let l:text  = s:Remove_block_comments(a:text)
    let l:lines = slime#common#lines(slime#common#tab_to_spaces(l:text))
    let [l:imports, l:nonImports] = s:FilterImportLines(l:lines)
    let l:lines = s:Remove_line_comments(l:nonImports)

    if g:slime_haskell_ghci_add_let
        let l:lines = s:Perhaps_prepend_let(l:lines)
        let l:lines = s:Indent_lines(l:lines)
    endif

    let l:lines = Wrap_if_multi(l:lines)
    return slime#common#unlines(l:imports + l:lines)
endfunction

function! _EscapeText_haskell_script(text)
    let l:text  = s:Remove_block_comments(a:text)
    let l:lines = slime#common#lines(slime#common#tab_to_spaces(l:text))
    let l:lines = s:Remove_line_comments(l:lines)
    return slime#common#unlines(l:lines)
endfunction
