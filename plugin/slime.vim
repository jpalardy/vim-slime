" vim: set foldmethod=marker:
" ================NOTES & DESCRIPTION======================================={{{1
" Name:          Slime
" Description:   Pastes the paragraph to a gnu screen, comparable with Slime
"                from Emacs
" Author:        Jonathan Palardy
" Webiste:       http://technotales.wordpress.com
" Last Modified: Thu 31 Mar 2011 10:59:43 AM CEST
" Version:       1.1
" Usage:         - Place the cursor inside the paragraph you want to be pasted
"                  to gnu screen.
"                - Call Send_to_Screen() to send the paragraph you are in
"               or
"                - Select the text you want to send and call Send_to_Screen()
"                - To change the screen vars call Screen_Vars()
"               note: you are advised to remap them, e.g.:
"                 Example: nnoremap <C-c><C-c> :call Send_to_Screen()<CR>
"                          vnoremap <C-c><C-c> :call Visual_Send_to_Screen()<CR>
"                          nnoremap <C-c>v :call Screen_Vars()<CR>
"
" Configuration: The following options can be customized in your vimrc:
"
"               slime_default_session (Default: "screen")
"                  The default screen name to display at the prompt
"                  Example: let g:slime_default_session = "myscreen"
"
"               slime_default_window  (Default: "0")
"                  The default screen window number to display at the prompt
"                  Example: let g:slime_default_window = "9"
" ==========================================================================}}}1
" Loaded Check {{{1
if exists("loaded_slime")
    finish
endif
let loaded_slime = 1
" Options {{{1
if !exists('g:slime_default_session')
    let g:slime_default_session = "screen"
endif
if !exists('g:slime_default_window')
    let g:slime_default_window  = "0"
endif
function Send_visual_to_Screen()

endfunction
function Send_to_Screen() " {{{1
    " save contents of register
    let old_r = @r

    normal! vip"ry
    call Visual_Send_to_Screen()
endfunction
function Visual_Send_to_Screen() "{{{1
    if !exists("b:slime")
        call Screen_Vars()
    end

    if !exists('old_r')
        " save contents of register
        let old_r = @r
        normal! gv"ry
    endif

    let s:text = @r

    let escaped_text = substitute(shellescape(@r), "\\\\\n", "\n", "g")
    call system("screen -S " . b:slime["sessionname"] . " -p "
    \            . b:slime["windowname"] . " -X stuff " . escaped_text)

    " restore contents
    let @r = old_r
    unlet old_r
endfunction

function Screen_Session_Names(A,L,P) "{{{1
    return system("screen -ls | awk '/Attached/ {print $1}'")
endfunction

function Screen_Vars() "{{{1
    if !exists("b:slime")
        let b:slime = {"sessionname": g:slime_default_session,
        \              "windowname": g:slime_default_window}
    end

    let b:slime["sessionname"] = input("session name: ",
    \   b:slime["sessionname"], "custom,Screen_Session_Names")
    let b:slime["windowname"] = input("window name: ",
    \   b:slime["windowname"])
endfunction
" vim: set foldmethod=marker:
