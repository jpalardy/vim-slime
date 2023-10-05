
function! s:X11Send(config, text)
  call system("xdotool type --delay 0 --window " . shellescape(b:slime_config["window_id"]) . " -- " . shellescape(a:text))
endfunction

function! s:X11Config() abort
  if !exists("b:slime_config")
    let b:slime_config = {"window_id": ""}
  end
  let b:slime_config["window_id"] = trim(system("xdotool selectwindow"))
endfunction

