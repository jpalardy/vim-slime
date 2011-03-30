" vim: set foldmethod=marker:
" ================NOTES & DESCRIPTION======================================={{{1
" Name:          Slime
" Description:   Pastes the paragraph to a gnu screen, comparable with Slime
"                from Emacs
" Author:        Jonathan Palardy
" Webiste:       http://technotales.wordpress.com
" Last Modified: Wed 30 Mar 2011 09:15:23 PM CEST
" Version:       1.1
" Usage:         - Place the cursor inside the paragraph you want to be pasted
"                  to gnu screen.
"                - Hit <C-c><C-c> and you will be prompted for your screen
"                  session name and window number
"                - To change these settings hit <C-c>v
" Configuration: The following options can be customized in your vimrc:
"                
"                slime_default_session (Default: "screen")
"                  The default screen name to display at the prompt
"                  Example: let g:slime_default_session = "myscreen"
"                slime_default_window  (Default: "0")
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
function Send_to_Screen() "{{{1
  if !exists("b:slime")
    call Screen_Vars()
  end

  " save contents of register
  let old_r = @r

  normal! gv"ry
  let s:text = @r

  "let escaped_text = substitute(shellescape(a:text), "\\\\\n", "\n", "g")
  let escaped_text = substitute(shellescape(@r), "\\\\\n", "\n", "g")
  call system("screen -S " . b:slime["sessionname"] . " -p " . b:slime["windowname"] . " -X stuff " . escaped_text)

  " restore contents
  let @r = old_r
endfunction

function Screen_Session_Names(A,L,P) "{{{1
  return system("screen -ls | awk '/Attached/ {print $1}'")
endfunction

function Screen_Vars() "{{{1
  if !exists("b:slime")
    let b:slime = {"sessionname": g:slime_default_session, "windowname": g:slime_default_window}
  end

  let b:slime["sessionname"] = input("session name: ", b:slime["sessionname"], "custom,Screen_Session_Names")
  let b:slime["windowname"] = input("window name: ", b:slime["windowname"])
endfunction
" Mappings {{{1
vmap <C-c><C-c> :call Send_to_Screen()<CR>
nmap <C-c><C-c> vip<C-c><C-c>

" Redefine the screen session name and window number
nmap <C-c>v :call Screen_Vars()<CR>
