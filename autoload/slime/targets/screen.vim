
function! s:ScreenSend(config, text)
  call s:WritePasteFile(a:text)
  call system("screen -S " . shellescape(a:config["sessionname"]) . " -p " . shellescape(a:config["windowname"]) .
        \ " -X eval \"readreg p " . slime#config#resolve("paste_file") . "\"")
  call system("screen -S " . shellescape(a:config["sessionname"]) . " -p " . shellescape(a:config["windowname"]) .
        \ " -X paste p")
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

