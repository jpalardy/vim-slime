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
endfunction

function! _EscapeText(text)
    return substitute(shellescape(a:text), "\\\\\\n", "\n", "g")
endfunction

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Public interface
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" TODO: refactoring
let g:slime_option = "tmux"

function! SlimeSend(text)
    if g:slime_option ==# "tmux"
        if !exists("b:slime_tmux")
            call TmuxConfig()
        end
        call TmuxSend(b:slime_tmux, a:text)
    elseif g:slime_option ==# "screen"
        if !exists("b:slime_screen")
            call ScreenConfig()
        end
        call ScreenSend(b:slime_screen, a:text)
    else
        echom g:slime_option . " is not a valid slime_option"
    endif
endfunction

function! SlimeConfig()
    if g:slime_option ==# "tmux"
        call TmuxConfig()
    elseif g:slime_option ==# "screen"
        call ScreenConfig()
    else
        echom g:slime_option . " is not a valid slime_option"
    endif
endfunction

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Setup key bindings
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
vmap <C-c><C-c> "ry:call SlimeSend(@r)<CR>
nmap <C-c><C-c> vip<C-c><C-c>

nmap <C-c>v :call SlimeConfig()<CR>
