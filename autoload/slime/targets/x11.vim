
function! slime#targets#x11#config() abort
  if !exists("b:slime_config")
    let b:slime_config = {"window_id": ""}
  end
  let b:slime_config["window_id"] = trim(system("xdotool selectwindow"))
endfunction

function! slime#targets#x11#send(config, text)
  call system("xdotool type --delay 0 --window " . shellescape(b:slime_config["window_id"]) . " -- " . shellescape(a:text))
endfunction

