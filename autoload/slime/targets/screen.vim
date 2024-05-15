
function! slime#targets#screen#config() abort
  if !exists("b:slime_config")
    let b:slime_config = {"sessionname": "", "windowname": "0"}
  end
  let b:slime_config["sessionname"] = input("screen session name: ", b:slime_config["sessionname"], "custom,slime#targets#screen#session_names")
  let b:slime_config["windowname"]  = input("screen window name: ",  b:slime_config["windowname"])
endfunction

function! slime#targets#screen#send(config, text)
  call slime#common#system('screen -S %s -p %s -X readreg p -', [a:config["sessionname"], a:config["windowname"]], a:text)
  call slime#common#system('screen -S %s -p %s -X paste p', [a:config["sessionname"], a:config["windowname"]])
endfunction

" -------------------------------------------------

function! slime#targets#screen#session_names(A,L,P)
  return slime#common#system("screen -ls | awk '/Attached/ {print $1}'", [])
endfunction

