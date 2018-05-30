set number
set nocompatible
set bs=2
set wrapmargin=8
syntax on
set ruler
set tabstop=4
set expandtab
if has("autocmd")
  au BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$")
    \| exe "normal! g'\"" | endif
endif
