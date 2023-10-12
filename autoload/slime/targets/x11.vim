
function! slime#targets#x11#config() abort
  if !exists("b:slime_config")
    let b:slime_config = {"window_id": ""}
  end
  let b:slime_config["window_id"] = trim(slime#common#system("xdotool selectwindow", []))
endfunction

function! slime#targets#x11#send(config, text)
  call slime#common#system("xdotool type --delay 0 --window %s -- %s", [a:config["window_id"], a:text])
endfunction

