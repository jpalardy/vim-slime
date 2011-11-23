"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Screen
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! ScreenSend(config, text)
    let escaped_text = _EscapeText(a:text)
    call system("screen -S " . a:config["sessionname"] . " -p " . a:config["windowname"] . " -X stuff " . escaped_text)
endfunction

" function! Screen_Session_Names(A,L,P)
"   return system("screen -ls | awk '/Attached/ {print $1}'")
" endfunction

function! ScreenConfig()
    if !exists("b:slime_screen")
        let b:slime_screen = {"sessionname": "", "windowname": "0"}
    end

    let b:slime_screen["sessionname"] = input("screen session name: ", b:slime_screen["sessionname"], "custom,Screen_Session_Names")
    let b:slime_screen["windowname"]  = input("screen window name: ", b:slime_screen["windowname"])
endfunction

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Tmux
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! TmuxSend(config, text)
    let escaped_text = _EscapeText(a:text)
    call system("tmux -L " . a:config["socket_name"] . " send-keys " . escaped_text)
endfunction

function! TmuxConfig()
    if !exists("b:slime_tmux")
        let b:slime_tmux = {"socket_name":""}
    end

    let b:slime_tmux["socket_name"] = input("tmux socket name: ", b:slime_tmux["socket_name"])
    " TODO: allow more tmux options? like window #, pane #?
endfunction

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Helpers
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! _EscapeText(text)
    return substitute(shellescape(a:text), "\\\\\\n", "\n", "g")
endfunction

function! _GetMuxDef(mux_defs, mux_name)
    if has_key(a:mux_defs, a:mux_name)
        return a:mux_defs[a:mux_name]
    else:
        return {}
endfunction

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Public interface
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:slime_option = "tmux"

let s:slime_muxes = {
            \ "tmux":{"fn_config":"TmuxConfig", "fn_send":"TmuxSend", "config_var":"slime_tmux"},
            \ "screen":{"fn_config":"ScreenConfig", "fn_send":"ScreenSend", "config_var":"slime_screen"}
            \ }

function! SlimeSend(text)
    let mux = _GetMuxDef(s:slime_muxes, g:slime_option)
    if empty(mux)
        echom g:slime_option . " is not a valid slime_option"
    else
        let Send = function(mux['fn_send'])
        let Config = function(mux['fn_config'])
        let config_var_name = mux['config_var']
        if !exists("b:".config_var_name)
            call Config()
        end
        call Send(eval("b:".config_var_name), a:text)
    end
endfunction

function! SlimeConfig()
    let mux = _GetMuxDef(s:slime_muxes, g:slime_option)
    if empty(mux)
        echom g:slime_option . " is not a valid slime_option"
    else
        let Config = function(mux['fn_config'])
        call Config()
    end
endfunction

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Setup key bindings
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
vmap <C-c><C-c> "ry:call SlimeSend(@r)<CR>
nmap <C-c><C-c> vip<C-c><C-c>

nmap <C-c>v :call SlimeConfig()<CR>
