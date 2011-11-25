
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Screen
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! ScreenSend(config, text)
  let escaped_text = _EscapeText(a:text)
  call system("screen -S " . a:config["sessionname"] . " -p " . a:config["windowname"] . " -X stuff " . escaped_text)
endfunction

function! ScreenSessionNames(A,L,P)
  return system("screen -ls | awk '/Attached/ {print $1}'")
endfunction

function! ScreenConfig()
  if !exists("b:slime_config")
    let b:slime_config = {"sessionname": "", "windowname": "0"}
  end

  let b:slime_config["sessionname"] = input("screen session name: ", b:slime_config["sessionname"], "custom,ScreenSessionNames")
  let b:slime_config["windowname"]  = input("screen window name: ",  b:slime_config["windowname"])
endfunction

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Tmux
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! TmuxSend(config, text)
  let escaped_text = _EscapeText(a:text)
  call system("tmux -L " . a:config["socket_name"] . " send-keys " . escaped_text)
endfunction

function! TmuxConfig()
  if !exists("b:slime_config")
    let b:slime_config = {"socket_name": "default"}
  end

  let b:slime_config["socket_name"] = input("tmux socket name: ", b:slime_config["socket_name"])
  " TODO: allow more tmux options? like window #, pane #?
endfunction

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Helpers
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! _EscapeText(text)
  return substitute(shellescape(a:text), "\\\\\\n", "\n", "g")
endfunction

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Public interface
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

if !exists("g:slime_target")
  let g:slime_target = "screen"
end

function! SlimeSend(text)
  if !exists("b:slime_config")
    call SlimeDispatch('Config')
  end
  call SlimeDispatch('Send', b:slime_config, a:text)
endfunction

function! SlimeConfig()
  call SlimeDispatch('Config')
endfunction

" delegation
function! SlimeDispatch(name, ...)
  let target = substitute(tolower(g:slime_target), '\(.\)', '\u\1', '') " Capitalize
  return call(target . a:name, a:000)
endfunction

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Setup key bindings
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

vmap <C-c><C-c> "ry:call SlimeSend(@r)<CR>
nmap <C-c><C-c> vip<C-c><C-c>

nmap <C-c>v :call SlimeConfig()<CR>

