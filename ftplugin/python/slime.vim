
function! _EscapeText_python(text)
  if exists('g:slime_python_ipython')
    return "%cpaste\n".a:text."--\n"
  else
    let no_empty_lines = substitute(a:text, '\n\s*\ze\n', "", "g")

    let lines = split(no_empty_lines, "\n")
    let edited_lines = []
    let last_line_was_indented = 0

    for line in lines
        "" Add empty lines between definitions (functions, loops, classes...)
        "" This is recognised by an indented line follow by an unindented one
        if ! s:lineIsIndented(line) && last_line_was_indented
            call add(edited_lines, "")
        endif

        call add(edited_lines, line)
        let last_line_was_indented = s:lineIsIndented(line)
    endfor

    "" Add an extra empty line to the end, if the last line is indented
    "" This closes the last definition
    if s:lineIsIndented(lines[-1])
        call add(edited_lines, "")
    endif

    "" An empty line at the end, so the cursor is on a new line
    call add(edited_lines, "")

    "" Now merge the list of strings back into a big string
    let some_empty_lines = join(edited_lines, "\n")

    return substitute(some_empty_lines, "\n", "", "g")
  end
endfunction

function s:lineIsIndented(line)
    let matched = match(a:line, '^\s') "starts with whitespace
    " 0 means it is indented
    return matched == 0
endfunction

