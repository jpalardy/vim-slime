"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Configuration
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

if !exists('g:slime_send_key')
  let g:slime_send_key = '<C-c><C-c>'
endif

if !exists('g:slime_config_key')
  let g:slime_config_key = '<C-c>v'
endif

if !exists("g:slime_target")
  let g:slime_target = "screen"
end

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Setup key bindings
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
execute 'vmap ' . g:slime_send_key . " \"ry:call <SID>SlimeSend(@r)<CR>"
execute 'nmap ' . g:slime_send_key . " vip" . g:slime_send_key
execute 'nmap ' . g:slime_config_key . " :call <SID>SlimeConfig()<CR>"

if exists('g:slime_loaded')
  finish
endif
let g:slime_loaded = 1


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Screen
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! s:ScreenSend(config, text)
  let escaped_text = s:_EscapeText(a:text)
  call system("screen -S " . a:config["sessionname"] . " -p " . a:config["windowname"] . " -X stuff " . escaped_text)
endfunction

" Leave this function exposed as it's called outside the plugin context
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
  call system("tmux -L " . a:config["socket_name"] . " send-keys -t" . a:config["target_pane"] . " " . escaped_text)
endfunction

function! s:TmuxConfig()
  if !exists("b:slime_config")
    let b:slime_config = {"socket_name": "default", "target_pane": ":"}
  end

  let b:slime_config["socket_name"] = input("tmux socket name: ", b:slime_config["socket_name"])
  let b:slime_config["target_pane"] = input("tmux target pane: ", b:slime_config["target_pane"])
endfunction

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Helpers
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! s:_EscapeText(text)
  let transformed_text = a:text

  if exists("&filetype")
    let custom_escape = "_EscapeText_" . &filetype
    if exists("*" . custom_escape)
        let transformed_text = call(custom_escape, [a:text])
    end
  end

  return substitute(shellescape(transformed_text), "\\\\\\n", "\n", "g")
endfunction

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Public interface
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

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
