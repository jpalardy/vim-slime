
function! slime#targets#conemu#config() abort
  " set destination for send commands, as specified in http://conemu.github.io/en/GuiMacro.html#Command_line
  if !exists("b:slime_config")
    " defaults to the active tab/split of the first found ConEmu window
    let b:slime_config = {"HWND": "0"}
  end
  let b:slime_config["HWND"] = input("Console server HWND: ", b:slime_config["HWND"])
endfunction

function! slime#targets#conemu#send(config, text)
  " Use the selection register to send text to ConEmu using the slime paste file
  let paste_file = slime#common#write_paste_file(a:text)
  call slime#common#system("conemuc -guimacro:%s pastefile 2 %s", [a:config["HWND"], paste_file])
endfunction

