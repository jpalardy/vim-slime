
function! slime#targets#zellij#config() abort
  if !exists("b:slime_config")
    let b:slime_config = {"session_id": "current", "relative_pane": "current"}
  end
  let b:slime_config["session_id"] = input("zellij session: ", b:slime_config["session_id"])
  let b:slime_config["relative_pane"] = input("target pane relative position: ", b:slime_config["relative_pane"])
  if b:slime_config["relative_pane"] == "current"
    let b:slime_config["relative_move_back"] = "current"
  elseif b:slime_config["relative_pane"] == "right"
    let b:slime_config["relative_move_back"] = "left"
  elseif b:slime_config["relative_pane"] == "left"
    let b:slime_config["relative_move_back"] = "right"
  elseif b:slime_config["relative_pane"] == "up"
    let b:slime_config["relative_move_back"] = "down"
  elseif b:slime_config["relative_pane"] == "down"
    let b:slime_config["relative_move_back"] = "up"
  else
    echoerr "Error: Allowed values are (current, right, left, up, down)"
  endif
endfunction

function! slime#targets#zellij#send(config, text)
  let target_cmd = s:target_cmd(a:config["session_id"])
  if a:config["relative_pane"] != "current"
    call slime#common#system(target_cmd . " action move-focus %s",  [a:config["relative_pane"]])
  end
  let [bracketed_paste, text_to_paste, has_crlf] = slime#common#bracketed_paste(a:text)

  if bracketed_paste
    call slime#common#system(target_cmd . " action write 27 91 50 48 48 126", [])
    call slime#common#system(target_cmd . " action write-chars %s", [text_to_paste])
    call slime#common#system(target_cmd . " action write 27 91 50 48 49 126", [])
    if has_crlf
      call slime#common#system(target_cmd . " action write 10", [])
    endif
  else
    call slime#common#system(target_cmd . " action write-chars %s", [text_to_paste])
  endif

  if a:config["relative_pane"] != "current"
    call slime#common#system(target_cmd . " action move-focus %s", [a:config["relative_move_back"]])
  end
endfunction

" -------------------------------------------------

function! s:target_cmd(session_id)
  if a:session_id != "current"
    return "zellij -s " . shellescape(a:session_id)
  end
  return "zellij"
endfunction

