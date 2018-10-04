if exists('g:loaded_slime') || &cp || v:version < 700
  finish
endif
let g:loaded_slime = 1

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Configuration
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

if !exists("g:slime_target")
  let g:slime_target = "screen"
end

if !exists("g:slime_preserve_curpos")
  let g:slime_preserve_curpos = 1
end

" screen and tmux need a file, so set a default if not configured
if !exists("g:slime_paste_file")
  let g:slime_paste_file = expand("$HOME/.slime_paste")
end

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Screen
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! s:ScreenSend(config, text)
  call s:WritePasteFile(a:text)
  call system("screen -S " . shellescape(a:config["sessionname"]) . " -p " . shellescape(a:config["windowname"]) .
        \ " -X eval \"readreg p " . g:slime_paste_file . "\"")
  call system("screen -S " . shellescape(a:config["sessionname"]) . " -p " . shellescape(a:config["windowname"]) .
        \ " -X paste p")
  call system('screen -X colon ""')
endfunction

function! s:ScreenSessionNames(A,L,P)
  return system("screen -ls | awk '/Attached/ {print $1}'")
endfunction

function! s:ScreenConfig() abort
  if !exists("b:slime_config")
    let b:slime_config = {"sessionname": "", "windowname": "0"}
  end
  let b:slime_config["sessionname"] = input("screen session name: ", b:slime_config["sessionname"], "custom,<SNR>" . s:SID() . "_ScreenSessionNames")
  let b:slime_config["windowname"]  = input("screen window name: ",  b:slime_config["windowname"])
endfunction

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Tmux
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! s:TmuxCommand(config, args)
  let l:socket = a:config["socket_name"]
  " For an absolute path to the socket, use tmux -S.
  " For a relative path to the socket in tmux's temporary directory, use tmux -L.
  " Case sensitivity does not matter here, but let's follow good practice.
  " TODO: Make this cross-platform. Windows supports tmux as of mid-2016.
  let l:socket_option = l:socket[0] ==? "/" ? "-S" : "-L"
  return system("tmux " . l:socket_option . " " . shellescape(l:socket) . " " . a:args)
endfunction

function! s:TmuxSend(config, text)
  call s:WritePasteFile(a:text)
  call s:TmuxCommand(a:config, "load-buffer " . g:slime_paste_file)
  call s:TmuxCommand(a:config, "paste-buffer -d -t " . shellescape(a:config["target_pane"]))
endfunction

function! s:TmuxPaneNames(A,L,P)
  let format = '#{pane_id} #{session_name}:#{window_index}.#{pane_index} #{window_name}#{?window_active, (active),}'
  return s:TmuxCommand(b:slime_config, "list-panes -a -F " . shellescape(format))
endfunction

function! s:TmuxConfig() abort
  if !exists("b:slime_config")
    let b:slime_config = {"socket_name": "default", "target_pane": ":"}
  end
  let b:slime_config["socket_name"] = input("tmux socket name or absolute path: ", b:slime_config["socket_name"])
  let b:slime_config["target_pane"] = input("tmux target pane: ", b:slime_config["target_pane"], "custom,<SNR>" . s:SID() . "_TmuxPaneNames")
  if b:slime_config["target_pane"] =~ '\s\+'
    let b:slime_config["target_pane"] = split(b:slime_config["target_pane"])[0]
  endif
endfunction

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Neovim Terminal
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! s:NeovimSend(config, text)
  " Neovim jobsend is fully asynchronous, it causes some problems with
  " iPython %cpaste (input buffering: not all lines sent over)
  " So this s:WritePasteFile can help as a small lock & delay
  call s:WritePasteFile(a:text)
  call jobsend(str2nr(a:config["jobid"]), split(a:text, "\n", 1))
endfunction

function! s:NeovimConfig() abort
  if !exists("b:slime_config")
    let b:slime_config = {"jobid": "1"}
  end
  let b:slime_config["jobid"] = input("jobid: ", b:slime_config["jobid"])
endfunction

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Conemu
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! s:ConemuSend(config, text)
  let l:prefix = "conemuc -guimacro:" . a:config["HWND"]
  " use the selection register to send text to ConEmu using the windows
  " clipboard (see help gui-clipboard)
  " save the current selection to restore it after send
  let tmp = @*
  let @* = a:text
  call system(l:prefix . " print")
  let @* = tmp
endfunction

function! s:ConemuConfig() abort
  " set destination for send commands, as specified in
  " http://conemu.github.io/en/GuiMacro.html#Command_line
  if !exists("b:slime_config")
    " defaults to the active tab/split of the first found ConEmu window
    let b:slime_config = {"HWND": "0"}
  end
  let b:slime_config["HWND"] = input("Console server HWND: ", b:slime_config["HWND"])
endfunction

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" whimrepl
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! s:WhimreplSend(config, text)
  call remote_send(a:config["server_name"], a:text)
endfunction

function! s:WhimreplConfig() abort
  if !exists("b:slime_config")
    let b:slime_config = {"server_name": "whimrepl"}
  end
  let b:slime_config["server_name"] = input("whimrepl server name: ", b:slime_config["server_name"])
endfunction

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" vim terminal
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! s:VimterminalSend(config, text)
  let bufnr = str2nr(get(a:config,"bufnr",""))
  if len(term_getstatus(bufnr))==0
    echoerr "Invalid terminal. Use :SlimeConfig to select a terminal"
    return
  endif
  " Ideally we ought to be able to use a single term_sendkeys call however as
  " of vim 8.0.1203 doing so can cause terminal display issues for longer
  " selections of text.
  for l in split(a:text,'\n\zs')
    call term_sendkeys(bufnr,substitute(l,'\n',"\r",''))
    call term_wait(bufnr)
  endfor
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
      let cmd = input("Enter a command to run [".&shell."]:")
      if len(cmd)==0
        let cmd = &shell
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


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Helpers
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! s:SID()
  return matchstr(expand('<sfile>'), '<SNR>\zs\d\+\ze_SID$')
endfun

function! s:WritePasteFile(text)
  " could check exists("*writefile")
  call system("cat > " . g:slime_paste_file, a:text)
endfunction

function! s:_EscapeText(text)
  if exists("&filetype")
    let custom_escape = "_EscapeText_" . substitute(&filetype, "[.]", "_", "g")
    if exists("*" . custom_escape)
      let result = call(custom_escape, [a:text])
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
  call s:SlimeDispatch('Config')
endfunction

function! s:SlimeSendOp(type, ...) abort
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
  call s:SlimeSend(@")

  let &selection = sel_save
  call setreg('"', rv, rt)

  call s:SlimeRestoreCurPos()
endfunction

function! s:SlimeSendRange(startline, endline) abort
  call s:SlimeGetConfig()

  let rv = getreg('"')
  let rt = getregtype('"')
  silent exe a:startline . ',' . a:endline . 'yank'
  call s:SlimeSend(@")
  call setreg('"', rv, rt)
endfunction

function! s:SlimeSendLines(count) abort
  call s:SlimeGetConfig()

  let rv = getreg('"')
  let rt = getregtype('"')
  silent exe 'normal! ' . a:count . 'yy'
  call s:SlimeSend(@")
  call setreg('"', rv, rt)
endfunction

function! s:SlimeStoreCurPos()
  if g:slime_preserve_curpos == 1
    let has_getcurpos = exists("*getcurpos")
    if has_getcurpos
      " getcurpos() doesn't exist before 7.4.313.
      let s:cur = getcurpos()
    else
      let s:cur = getpos('.')
    endif
  endif
endfunction

function! s:SlimeRestoreCurPos()
  if g:slime_preserve_curpos == 1 && exists("s:cur")
    call setpos('.', s:cur)
    unlet s:cur
  endif
endfunction

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Public interface
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! s:SlimeSend(text)
  call s:SlimeGetConfig()

  " this used to return a string, but some receivers (coffee-script)
  " will flush the rest of the buffer given a special sequence (ctrl-v)
  " so we, possibly, send many strings -- but probably just one
  let pieces = s:_EscapeText(a:text)
  for piece in pieces
    call s:SlimeDispatch('Send', b:slime_config, piece)
  endfor
endfunction

function! s:SlimeConfig() abort
  call inputsave()
  call s:SlimeDispatch('Config')
  call inputrestore()
endfunction

" delegation
function! s:SlimeDispatch(name, ...)
  let target = substitute(tolower(g:slime_target), '\(.\)', '\u\1', '') " Capitalize
  return call("s:" . target . a:name, a:000)
endfunction

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Setup key bindings
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

command -bar -nargs=0 SlimeConfig call s:SlimeConfig()
command -range -bar -nargs=0 SlimeSend call s:SlimeSendRange(<line1>, <line2>)
command -nargs=+ SlimeSend1 call s:SlimeSend(<q-args> . "\r")
command -nargs=+ SlimeSend0 call s:SlimeSend(<args>)
command! SlimeSendCurrentLine call s:SlimeSend(getline(".") . "\r")

noremap <SID>Operator :<c-u>call <SID>SlimeStoreCurPos()<cr>:set opfunc=<SID>SlimeSendOp<cr>g@

noremap <unique> <script> <silent> <Plug>SlimeRegionSend :<c-u>call <SID>SlimeSendOp(visualmode(), 1)<cr>
noremap <unique> <script> <silent> <Plug>SlimeLineSend :<c-u>call <SID>SlimeSendLines(v:count1)<cr>
noremap <unique> <script> <silent> <Plug>SlimeMotionSend <SID>Operator
noremap <unique> <script> <silent> <Plug>SlimeParagraphSend <SID>Operatorip
noremap <unique> <script> <silent> <Plug>SlimeConfig :<c-u>SlimeConfig<cr>

if !exists("g:slime_no_mappings") || !g:slime_no_mappings
  if !hasmapto('<Plug>SlimeRegionSend', 'x')
    xmap <c-c><c-c> <Plug>SlimeRegionSend
  endif

  if !hasmapto('<Plug>SlimeParagraphSend', 'n')
    nmap <c-c><c-c> <Plug>SlimeParagraphSend
  endif

  if !hasmapto('<Plug>SlimeConfig', 'n')
    nmap <c-c>v <Plug>SlimeConfig
  endif
endif

