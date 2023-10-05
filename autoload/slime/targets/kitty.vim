
function! s:KittySend(config, text)
  let bracketed_paste = slime#config#resolve("bracketed_paste")

  let [text_to_paste, has_crlf] = [a:text, 0]
  if bracketed_paste
    if a:text[-2:] == "\r\n"
      let [text_to_paste, has_crlf] = [a:text[:-3], 1]
    elseif a:text[-1:] == "\r" || a:text[-1:] == "\n"
      let [text_to_paste, has_crlf] = [a:text[:-2], 1]
    endif
    let text_to_paste = "\e[200~" . text_to_paste . "\e[201~"
  endif

  let to_flag = ""
  if a:config["listen_on"] != ""
    let to_flag = " --to " . shellescape(a:config["listen_on"])
  end

  call system("kitty @" . to_flag . " send-text --match id:" . shellescape(a:config["window_id"]) . " --stdin", text_to_paste)
endfunction

function! s:KittyConfig() abort
  if !exists("b:slime_config")
    let b:slime_config = {"window_id": 1, "listen_on": ""}
  end
  let b:slime_config["window_id"] = str2nr(system("kitty @ select-window --self"))
  if v:shell_error || b:slime_config["window_id"] == $KITTY_WINDOW_ID
    let b:slime_config["window_id"] = input("kitty window_id: ", b:slime_config["window_id"])
  endif
  let b:slime_config["listen_on"] = input("kitty listen on: ", b:slime_config["listen_on"])
endfunction

