
function! slime#targets#dtach#config() abort
  if !exists("b:slime_config")
    let b:slime_config = {"socket_path": "/tmp/slime"}
  end
  let b:slime_config["socket_path"] = input("dtach socket path: ", b:slime_config["socket_path"])
endfunction

function! slime#targets#dtach#send(config, text)
  call slime#common#system("dtach -p %s", [a:config["socket_path"]], a:text)
endfunction

