
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Helpers
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! s:_EscapeText(text)
  let escape_text_fn = "_EscapeText_" . substitute(&filetype, "[.]", "_", "g")
  if exists("&filetype")
    let override_fn = "SlimeOverride" . escape_text_fn
    if exists("*" . override_fn)
      let result = call(override_fn, [a:text])
    elseif exists("*" . escape_text_fn)
      let result = call(escape_text_fn, [a:text])
    end
  end

  " use a:text if the ftplugin didn't kick in
  if !exists("result")
    let result = a:text
  end

  " return an array, regardless
  if type(result) == type("")
    return [result]
  else
    return result
  end
endfunction

function! s:SlimeGetConfig()
  " b:slime_config already configured...
  if exists("b:slime_config")
    return
  end
  " assume defaults, if they exist
  if exists("g:slime_default_config")
    let b:slime_config = g:slime_default_config
  end
  " skip confirmation, if configured
  if exists("g:slime_dont_ask_default") && g:slime_dont_ask_default
    return
  end
  " prompt user
  call s:SlimeDispatch('config')
endfunction

function! slime#send_op(type, ...) abort
  call s:SlimeGetConfig()

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
endfunction

function! slime#send_range(startline, endline) abort
  call s:SlimeGetConfig()

  let rv = getreg('"')
  let rt = getregtype('"')
  silent exe a:startline . ',' . a:endline . 'yank'
  call slime#send(@")
  call setreg('"', rv, rt)
endfunction

function! slime#send_lines(count) abort
  call s:SlimeGetConfig()

  let rv = getreg('"')
  let rt = getregtype('"')
  silent exe 'normal! ' . a:count . 'yy'
  call slime#send(@")
  call setreg('"', rv, rt)
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
  call s:SlimeGetConfig()

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
    end
  endfor
endfunction

function! slime#config() abort
  call inputsave()
  call s:SlimeDispatch('config')
  call inputrestore()
endfunction

" delegation
function! s:SlimeDispatch(name, ...)
  " allow custom override
  let override_fn = "SlimeOverride" . slime#common#capitalize(a:name)
  if exists("*" . override_fn)
    return call(override_fn, a:000)
  end
  return call("slime#targets#" . slime#config#resolve("target") . "#" . a:name, a:000)
endfunction

