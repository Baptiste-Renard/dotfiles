# **Vim Tips**

## Man pages

`shift + k` to bring up the **man page** of the current word.

## Search for the current word

`*` to search and highlight the current selected word, and `#` for reverse search.

## Interact with the shell

`:!command` to execute "command" in the shell.
`:r !command` to insert the output of "command" from the shell.
`:w !command` to insert the current selection to "command". (w !wl-copy)

## Indenting

The keys `>` and `<` are used to indent/unindent.
In **visual Line mode**, they indent/unindent every selected line
Use `>>` or `<<` indent/unindent the current line.

`=` is used to auto-indenting, `==` auto-indents the current line.

## Multi-line edit

In **Visual Line Mode**, use `norm I//` to comment the lines.
Use `norm @q` to execute macro q to all selected lines.
(Be careful when using macros that insert new lines,
the macro will be applied to them next)

## Hexdump editing

Convert file to a hexdump with `:%!xxd`.
Once done use `:%!xxd -r` to switch back.

In general `:%!command` will run the command with your file as stdin
and replace your file it with the output of the command.

## Windows

`new` or `vnew` to create new horizontal/vertical window.
You can add a filename too with `new/vnew filename`.
`close`/`clo` to close the current window.
`only`/`on` to close all other windows.

You can also use `ctrl+w` prefix instead of the command mode.
`ctrl+w + h/j/k/l` to move around windows.
`ctrl+w + H/J/K/K` window around.
`ctrl+w + w/p` to cycle forward/backwards windows.
`ctrl+w + =` to equalize window sizes.
`ctrl+w + +/-/</>` to increase/decrease height/width
