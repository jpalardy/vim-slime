
function! s:VimterminalSend(config, text)
  let bufnr = str2nr(get(a:config,"bufnr",""))
  if len(term_getstatus(bufnr))==0
    echoerr "Invalid terminal. Use :SlimeConfig to select a terminal"
    return
  endif
  " send the text, translating newlines to enter keycode for Windows or any
  " other platforms where they are not the same
  call term_sendkeys(bufnr,substitute(a:text,'\n',"\r",'g'))
endfunction

function! s:VimterminalDescription(idx,info)
  let title = term_gettitle(a:info.bufnr)
  if len(title)==0
    let title = term_getstatus(a:info.bufnr)
  endif
  return printf("%2d.%4d %s [%s]",a:idx,a:info.bufnr,a:info.name,title)
endfunction

function! s:VimterminalConfig() abort
  if !exists("*term_start")
    echoerr "vimterminal support requires vim built with :terminal support"
    return
  endif
  if !exists("b:slime_config")
    let b:slime_config = {"bufnr": ""}
  end
  let bufs = filter(term_list(),"term_getstatus(v:val)=~'running'")
  let terms = map(bufs,"getbufinfo(v:val)[0]")
  let choices = map(copy(terms),"s:VimterminalDescription(v:key+1,v:val)")
  call add(choices, printf("%2d. <New instance>",len(terms)+1))
  let choice = len(choices)>1
        \ ? inputlist(choices)
        \ : 1
  if choice > 0
    if choice>len(terms)
      if exists("b:slime_vimterminal_cmd")
        let cmd = b:slime_vimterminal_cmd
      elseif exists("g:slime_vimterminal_cmd")
        let cmd = g:slime_vimterminal_cmd
      else
        let cmd = input("Enter a command to run [".&shell."]:")
        if len(cmd)==0
          let cmd = &shell
        endif
      endif
      let winid = win_getid()
      if exists("g:slime_vimterminal_config")
        let new_bufnr = term_start(cmd, g:slime_vimterminal_config)
      else
        let new_bufnr = term_start(cmd)
      end
      call win_gotoid(winid)
      let b:slime_config["bufnr"] = new_bufnr
    else
      let b:slime_config["bufnr"] = terms[choice-1].bufnr
    endif
  endif
endfunction

