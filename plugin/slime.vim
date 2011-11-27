
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Screen
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! s:ScreenSend(config, text)
  let escaped_text = s:_EscapeText(a:text)
  call system("screen -S " . a:config["sessionname"] . " -p " . a:config["windowname"] . " -X stuff " . escaped_text)
endfunction

function! ScreenSessionNames(A,L,P)
  return system("screen -ls | awk '/Attached/ {print $1}'")
endfunction

function! s:ScreenConfig()
  if !exists("b:slime_config")
    let b:slime_config = {"sessionname": "", "windowname": "0"}
  end

  let b:slime_config["sessionname"] = input("screen session name: ", b:slime_config["sessionname"], "custom,ScreenSessionNames")
  let b:slime_config["windowname"]  = input("screen window name: ",  b:slime_config["windowname"])
endfunction

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Tmux
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! s:TmuxSend(config, text)
  let escaped_text = s:_EscapeText(a:text)
  call system("tmux -L " . a:config["socket_name"] . " send-keys " . escaped_text)
endfunction

function! s:TmuxConfig()
  if !exists("b:slime_config")
    let b:slime_config = {"socket_name": "default"}
  end

  let b:slime_config["socket_name"] = input("tmux socket name: ", b:slime_config["socket_name"])
  " TODO: allow more tmux options? like window #, pane #?
endfunction

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Helpers
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! s:_EscapeText(text)
  return substitute(shellescape(a:text), "\\\\\\n", "\n", "g")
endfunction

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Public interface
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

if !exists("g:slime_target")
  let g:slime_target = "screen"
end

function! s:SlimeSend(text)
  if !exists("b:slime_config")
    call s:SlimeDispatch('Config')
  end
  call s:SlimeDispatch('Send', b:slime_config, a:text)
endfunction

function! s:SlimeConfig()
  call s:SlimeDispatch('Config')
endfunction

" delegation
function! s:SlimeDispatch(name, ...)
  let target = substitute(tolower(g:slime_target), '\(.\)', '\u\1', '') " Capitalize
  return call("s:" . target . a:name, a:000)
endfunction

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Setup key bindings
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

vmap <C-c><C-c> "ry:call <SID>SlimeSend(@r)<CR>
nmap <C-c><C-c> vip<C-c><C-c>

nmap <C-c>v :call <SID>SlimeConfig()<CR>

