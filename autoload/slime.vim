
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Helpers
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" takes any number of strings as arguments: if one of those strings exists
" as an environment variable in vim, return its value, if none of them exist
" return v:null
function! s:resolve(...)
  for name in a:000
    if exists(name)
      return eval(name)
    endif
  endfor
  return v:null
endfunction

" takes any number of strings as arguments: if one of those strings exists
" as an environment variable in vim, return its value, if none of them exist
" return 'default' arg
function! s:resolve_default(default, ...)
  for name in a:000
    if exists(name)
      return eval(name)
    endif
  endfor
  " 0 means false
  return a:default
endfunction

function! s:_EscapeText(text)
  let escape_text_fn = "_EscapeText_" . substitute(&filetype, "[.]", "_", "g")
  if exists("&filetype")
    let override_fn = "SlimeOverride" . escape_text_fn
    if exists("*" . override_fn)
      let result = call(override_fn, [a:text])
    elseif exists("*" . escape_text_fn)
      let result = call(escape_text_fn, [a:text])
    endif
  endif

  " use a:text if the ftplugin didn't kick in
  if !exists("result")
    let result = a:text
  endif

  " return an array, regardless
  if type(result) == type("")
    return [result]
  else
    return result
  endif
endfunction

"function! s:SlimeGetConfig()
"  " b:slime_config already configured...
"  if exists("b:slime_config") 
"    if s:SlimeDispatch("ValidConfig", b:slime_config)
"      return
"    endif
"  endif
"  " assume defaults, if they exist
"  if exists("g:slime_default_config")
"    let b:slime_config = g:slime_default_config
"  endif
"
"	if b:slime_config is v:null  || !s:SlimeDispatch("ValidConfig" , b:slime_config) 
"		let b:slime_config = {}
"    echo
"	endif
"  " skip confirmation, if configured
"  if exists("g:slime_dont_ask_default") && g:slime_dont_ask_default
"    return
"  endif
"  " prompt user
"  call s:SlimeDispatch('config')
"  
"  if !s:SlimeDispatch('ValidConfig',b:config)
"  endif
"
"endfunction



function! s:SlimeGetConfig()
  " b:slime_config already configured...
  if exists("b:slime_config")
    if s:SlimeDispatch("ValidConfig", b:slime_config)
      return
    endif
  endif
  " assume defaults, if they exist
  if exists("g:slime_default_config")
    let b:slime_config = g:slime_default_config

    " skip confirmation, if configured
    if exists("g:slime_dont_ask_default") && g:slime_dont_ask_default
      return
    endif

    if !s:SlimeDispatch("ValidConfig", b:slime_config)
      unlet b:slime_config
    endif

  endif
  " prompt user
  call s:SlimeDispatch('config')

  if s:SlimeDispatch("ValidConfig", b:slime_config)
    return
  else
    unlet b:slime_config
    throw "invalid config"
  endif

endfunction



function! slime#send_op(type, ...) abort
  if s:SlimeDispatch("ValidEnv")
    try
      call s:SlimeGetConfig()
    catch \invalid config\
      return
    endtry

    let sel_save = &selection
    let &selection = "inclusive"
    let rv = getreg('"')
    let rt = getregtype('"')

    if a:0  " Invoked from Visual mode, use '< and '> marks.
      silent exe "normal! `<" . a:type . '`>y'
    elseif a:type == 'line'
      silent exe "normal! '[V']y"
    elseif a:type == 'block'
      silent exe "normal! `[\<C-V>`]\y"
    else
      silent exe "normal! `[v`]y"
    endif

    call setreg('"', @", 'V')
    call slime#send(@")

    let &selection = sel_save
    call setreg('"', rv, rt)

    call s:SlimeRestoreCurPos()
  endif
endfunction

function! slime#send_range(startline, endline) abort
  if s:SlimeDispatch("ValidEnv")
    try
      call s:SlimeGetConfig()
    catch \invalid config\
      return
    endtry

    let rv = getreg('"')
    let rt = getregtype('"')
    silent exe a:startline . ',' . a:endline . 'yank'
    call slime#send(@")
    call setreg('"', rv, rt)
  endif
endfunction

function! slime#send_lines(count) abort
  if s:SlimeDispatch("ValidEnv")
    try
      call s:SlimeGetConfig()
    catch \invalid config\
      return
    endtry

    let rv = getreg('"')
    let rt = getregtype('"')
    silent exe 'normal! ' . a:count . 'yy'
    call slime#send(@")
    call setreg('"', rv, rt)
  endif
endfunction

function! slime#send_cell() abort
  let cell_delimiter = slime#config#resolve("cell_delimiter")
  if cell_delimiter == v:null
    return
  endif

  let line_ini = search(cell_delimiter, 'bcnW')
  let line_end = search(cell_delimiter, 'nW')

  " line after delimiter or top of file
  let line_ini = line_ini ? line_ini + 1 : 1
  " line before delimiter or bottom of file
  let line_end = line_end ? line_end - 1 : line("$")

  if line_ini <= line_end
    call slime#send_range(line_ini, line_end)
  endif
endfunction

function! slime#store_curpos()
  if slime#config#resolve("preserve_curpos")
    let s:cur = winsaveview()
  endif
endfunction

function! s:SlimeRestoreCurPos()
  if slime#config#resolve("preserve_curpos") && exists("s:cur")
    call winrestview(s:cur)
    unlet s:cur
  endif
endfunction

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Public interface
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! slime#send(text)

  if s:SlimeDispatch("ValidEnv")
    try
      call s:SlimeGetConfig()
    catch \invalid config\
      return
    endtry

    " this used to return a string, but some receivers (coffee-script)
    " will flush the rest of the buffer given a special sequence (ctrl-v)
    " so we, possibly, send many strings -- but probably just one
    let pieces = s:_EscapeText(a:text)
    for piece in pieces
      if type(piece) == 0  " a number
        if piece > 0  " sleep accepts only positive count
          execute 'sleep' piece . 'm'
        endif
      else
        call s:SlimeDispatch('send', b:slime_config, piece)
      endif
    endfor
  endif
endfunction


function! slime#config() abort
  call inputsave()
  if s:SlimeDispatch("ValidEnv")
    call s:SlimeDispatch('config')

    if !s:SlimeDispatch("ValidConfig", b:slime_config)
      unlet b:slime_config
      throw "invalid config"
    endif
  endif
  call inputrestore()
endfunction

" delegation
function! s:SlimeDispatch(name, ...)
  " allow custom override
  let override_fn = "SlimeOverride" . slime#common#capitalize(a:name)
  if exists("*" . override_fn)
    return call(override_fn, a:000)
  endif

  let fun_string = "slime#targets#" . slime#config#resolve("target") . "#" . a:name
  if exists("*" . fun_string)
    return call(fun_string, a:000)
  endif

  "1 means true
  return 1
endfunction

