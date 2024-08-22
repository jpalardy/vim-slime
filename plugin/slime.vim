if exists('g:loaded_slime') || &cp || v:version < 700
  finish
endif
let g:loaded_slime = 1

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Setup key bindings
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

command -bar -nargs=0 SlimeConfig call slime#config()
command -range -bar -nargs=0 SlimeSend call slime#send_range(<line1>, <line2>)
command -nargs=+ SlimeSend1 call slime#send(<q-args> . "\r")
command -nargs=+ SlimeSend0 call slime#send(<args>)
command! SlimeSendCurrentLine call slime#send(getline(".") . "\r")


noremap <SID>Operator :<c-u>call slime#store_curpos()<cr>:set opfunc=slime#send_op<cr>g@

noremap <unique> <script> <silent> <Plug>SlimeRegionSend :<c-u>call slime#send_op(visualmode(), 1)<cr>
noremap <unique> <script> <silent> <Plug>SlimeLineSend :<c-u>call slime#send_lines(v:count1)<cr>
noremap <unique> <script> <silent> <Plug>SlimeMotionSend <SID>Operator
noremap <unique> <script> <silent> <Plug>SlimeParagraphSend <SID>Operatorip
noremap <unique> <script> <silent> <Plug>SlimeConfig :<c-u>SlimeConfig<cr>
noremap <unique> <script> <silent> <Plug>SlimeSendCell :<c-u>call slime#send_cell()<cr>

if !exists("g:slime_no_mappings") || !g:slime_no_mappings
  if !hasmapto('<Plug>SlimeRegionSend', 'x')
    xmap <c-c><c-c> <Plug>SlimeRegionSend
  endif

  if !hasmapto('<Plug>SlimeParagraphSend', 'n')
    nmap <c-c><c-c> <Plug>SlimeParagraphSend
  endif

  if !hasmapto('<Plug>SlimeConfig', 'n')
    nmap <c-c>v <Plug>SlimeConfig
  endif
endif

" for neovim (only), make slime_last_channel contain
" the channel id of the last opened terminal
if slime#config#resolve("target") == "neovim"
  if has('nvim')
    augroup nvim_slime
      autocmd!
      " keeping track of channels that are open
      autocmd TermOpen * call slime#targets#neovim#SlimeAddChannel(expand('<abuf>'))
      " keeping track when terminals are closed
      autocmd TermClose * call slime#targets#neovim#SlimeClearChannel(expand('<abuf>'))
    augroup END
  else
    call slime#targets#neovim#EchoWarningMsg("Trying to use Neovim target in standard Vim. This won't work.")
  endif
endif
