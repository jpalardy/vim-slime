""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function Send_to_Screen(text)
  if !exists("b:slime")
    call Screen_Vars()
  end

  let escaped_text = substitute(shellescape(a:text), "\\\\\n", "\n", "g")
  call system("screen -S " . b:slime["sessionname"] . " -p " . b:slime["windowname"] . " -X stuff " . escaped_text)
endfunction

function Send_Coffee_to_NodeRepl_Screen(text)
  if !exists("b:slime")
    call Screen_Vars()
  end

  let escaped_text = substitute(shellescape(a:text), "\\\\\n", "\n", "g")
  let l:compiled_text = system("coffee -bep " . escaped_text)
  let l:escaped_compiled_text = substitute(shellescape(l:compiled_text), "\\\\\n", "\n", "g")
  call system("screen -S " . b:slime["sessionname"] . " -p " . b:slime["windowname"] . " -X stuff " . l:escaped_compiled_text)
endfunction

function Screen_Session_Names(A,L,P)
  return system("screen -ls | awk '/Attached/ {print $1}'")
endfunction

function Screen_Vars()
  if !exists("b:slime")
    let b:slime = {"sessionname": "", "windowname": "0"}
  end

  let b:slime["sessionname"] = input("session name: ", b:slime["sessionname"], "custom,Screen_Session_Names")
  let b:slime["windowname"]  = input("window name: ", b:slime["windowname"])
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

vmap <C-c><C-c> "ry:call Send_to_Screen(@r)<CR>
nmap <C-c><C-c> vip<C-c><C-c>

" Ctrl-C, Ctrl-S will compile coffee code and then send results to the
" connected screen
vmap <C-c><C-s> "ry:call Send_Coffee_to_NodeRepl_Screen(@r)<CR>

nmap <C-c>v :call Screen_Vars()<CR>
