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

function! slime#common#capitalize(text)
  return substitute(tolower(a:text), '\(.\)', '\u\1', '')
endfunction

function! slime#common#system(cmd_template, args, ...)
  if &l:shell !=# "cmd.exe"
      let escaped_args = map(copy(a:args), "shellescape(v:val)")
  else
      let escaped_args = a:args
  endif

  let cmd = call('printf', [a:cmd_template] + escaped_args)

  if slime#config#resolve("debug")
    echom "slime system: " . cmd
  endif

  if a:0 == 0
    return system(cmd)
  endif
  return system(cmd, a:1)
endfunction

function! slime#common#bracketed_paste(text)
  let bracketed_paste = slime#config#resolve("bracketed_paste")

  if bracketed_paste == 0
    return [bracketed_paste, a:text, 0]
  endif

  let text_to_paste = substitute(a:text, '\(\r\n\|\r\|\n\)$', '', '')
  let has_crlf = strlen(a:text) != strlen(text_to_paste)

  return [bracketed_paste, text_to_paste, has_crlf]
endfunction
