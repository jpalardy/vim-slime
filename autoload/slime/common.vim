" guess correct number of spaces to indent
" (tabs cause 'no completion found' messages)
function! slime#common#get_indent_string() abort
  return repeat(" ", 4)
endfunction

" replace tabs by spaces
function! slime#common#tab_to_spaces(text) abort
  return substitute(a:text, "\t", slime#common#get_indent_string(), "g")
endfunction

" change string into array of lines
function! slime#common#lines(text) abort
  return split(a:text, "\n")
endfunction

" change lines back into text
function! slime#common#unlines(lines) abort
  return join(a:lines, "\n") . "\n"
endfunction

function! slime#common#write_paste_file(text)
  let paste_dir = fnamemodify(slime#config#resolve("paste_file"), ":p:h")
  if !isdirectory(paste_dir)
    call mkdir(paste_dir, "p")
  endif
  let output = slime#common#system("cat > %s", [slime#config#resolve("paste_file")], a:text)
  if v:shell_error
    echoerr output
  endif
endfunction

function! slime#common#capitalize(text)
  return substitute(tolower(a:text), '\(.\)', '\u\1', '')
endfunction

function! slime#common#system(cmd_template, args, ...)
  let escaped_args = map(copy(a:args), "shellescape(v:val)")
  return call('system', [call('printf', [a:cmd_template] + escaped_args)] + a:000)
endfunction
