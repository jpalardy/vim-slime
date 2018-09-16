function! _EscapeText_stata(text)
	let remove_comments = substitute(a:text, '///\s*\n', " ", "g")
	return remove_comments
endfunction
