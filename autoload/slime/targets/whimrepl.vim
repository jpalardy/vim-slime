
function! s:WhimreplSend(config, text)
  call remote_send(a:config["server_name"], a:text)
endfunction

function! s:WhimreplConfig() abort
  if !exists("b:slime_config")
    let b:slime_config = {"server_name": "whimrepl"}
  end
  let b:slime_config["server_name"] = input("whimrepl server name: ", b:slime_config["server_name"])
endfunction

