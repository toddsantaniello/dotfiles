nnoremap <leader>jf :%!jq .<CR>

" Absolute number on the cursor line, relative numbers elsewhere for jumps like 5j
set number relativenumber

" In git rebase -i todo lists, \s turns the current line's command into squash
filetype plugin on
autocmd FileType gitrebase nnoremap <buffer> <leader>s 0dwIs<SPACE><ESC>j
