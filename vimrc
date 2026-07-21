" make `~/.vimrc` link to this file
"spaces
set expandtab          "spaces on tab
set tabstop=4          "visual width of tabs
set softtabstop=4      "amount of spaces to insert/delete on tab
set shiftwidth=4       "auto indenting
set smartindent

"decoration
set cursorline
"set number

"search
set hlsearch           "highlight search
set incsearch          "search as you type
set ignorecase

"dump
syntax on
set encoding=utf-8
set hidden             "switch buffers without having to save them
set nocompatible
filetype plugin on
set exrc               "execute .vimrc in working directory
set secure
"set path+=**          "add all files recursively to path (for the find command)
set wildmenu
"set mouse=a            "allow mouse select (can mess up terminal copy/paste)
