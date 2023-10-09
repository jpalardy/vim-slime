
function! slime#targets#whimrepl#config() abort
  if !exists("b:slime_config")
    let b:slime_config = {"server_name": "whimrepl"}
  end
  let b:slime_config["server_name"] = input("whimrepl server name: ", b:slime_config["server_name"])
endfunction

function! slime#targets#whimrepl#send(config, text)
  call remote_send(a:config["server_name"], a:text)
endfunction

