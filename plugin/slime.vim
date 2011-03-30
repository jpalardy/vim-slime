
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function Send_to_Screen()
  if !exists("b:slime")
    call Screen_Vars()
  end

  " save the old register
  let old_r = @r
  " copy the selected text to @r
  normal! gv"ry

  " you can directly use @r here
  let escaped_text = substitute(shellescape(@r), "\\\\\n", "\n", "g")
  call system("screen -S " . b:slime["sessionname"] . " -p " . b:slime["windowname"] . " -X stuff " . escaped_text)
  " restore the register
  let @r = old_r
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

" the space before the :call breaks a <space> mapping
vmap <C-c><C-c> :call Send_to_Screen()<CR>
nmap <C-c><C-c> vip<C-c><C-c>

nmap <C-c>v :call Screen_Vars()<CR>

