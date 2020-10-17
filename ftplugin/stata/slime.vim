function! _EscapeText_stata(text)
	let remove_comments = substitute(a:text, '///\s*\n', " ", "g")
	let remove_comments = substitute(remove_comments, '//.*\n', "\n", "g")
	let remove_comments = substitute(remove_comments, '/\*.*\*/', "", "g")
	return remove_comments
endfunction
