if exists('g:loaded_slime') || &cp || v:version < 700
  finish
endif
let g:loaded_slime = 1

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Setup key bindings
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

command -bar -nargs=0 ExamplePlug colorscheme blue
noremap <unique> <script> <silent> <Plug>(ChangeColor) :<c-u>ExamplePlug<cr>

command -bar -nargs=0 ExamplePlug2 colorscheme peachpuff
noremap <unique> <script> <silent> <Plug>(ChangeColor2) :<c-u>ExamplePlug2<cr>

nmap <leader>pp <Plug>(ChangeColor2)<Plug>(ChangeColor)

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

if has('nvim') && get(g:, "slime_target", "") == "neovim"

lua << EOF

	local slime_autocmds = vim.api.nvim_create_augroup("nvim_slime", { clear = true })

	vim.api.nvim_create_autocmd("TermOpen", {
		pattern = "*",
		callback = function()
		vim.cmd([[

		]])
			vim.g.slime_last_channel = vim.api.nvim_eval("&channel")
		end,
		group = slime_autocmds
	})

	vim.api.nvim_create_autocmd("TermClose", {
		pattern = "*",
		callback = function() 			
			if vim.g.slime_last_channel == vim.api.nvim_eval("&channel") then
				vim.cmd([[unlet vim.g.slime_last_channel]])
			end

		end,
		group = slime_autocmds
	})

EOF

endif


nmap gz <Plug>SlimeMotionSend
nmap gzz <Plug>SlimeLineSend
xmap gz <Plug>SlimeRegionSend
