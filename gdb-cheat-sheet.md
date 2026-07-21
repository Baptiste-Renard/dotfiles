# GDB Useful Commands (C / C++)

This document is a concise but comprehensive reference for common and useful GDB commands when debugging C and C++ programs.

---

## 1. Compiling for Debugging

```bash
gcc -g -O0 main.c -o main
```

- `-g` enables debug symbols (lines, variables, functions)
- `-O0` disables optimizations (strongly recommended)

---

## 2. Starting and Stopping Execution

```gdb
run / c             # Start program from beginning
continue / c        # Continue to next breakpoint
kill                # Kill the debugged process
quit / q            # Exit GDB
```

Interrupt a running program:
```
Ctrl-C
```

---

## 3. Breakpoints

### Set Breakpoints

```gdb
break main                   # Break at function
break file.c:42              # Break at specific line
break 42                     # Break at line in current file
```

### Conditional Breakpoints

```gdb
break foo if x == 10
break file.c:42 if x == 10
```

### List Breakpoints

```gdb
info breakpoints
info break
```

### Enable / Disable Breakpoints

```gdb
disable 1
enable 1
```

### Delete (Clear) Breakpoints

```gdb
delete                 # Delete ALL breakpoints
delete 1               # Delete breakpoint number 1
delete 1 2 3           # Delete multiple breakpoints
clear                   # Clear breakpoint at current line
clear file.c:42         # Clear breakpoint at specific line
clear function_name     # Clear breakpoint at function
```

---

## 4. Stepping Through Code

```gdb
next / n            # Step over function calls
step / s            # Step into function calls
finish              # Run until current function returns
continue            # Continue execution of the program, stop at a breakpoint
```

---

## 5. Viewing Source and Location

```gdb
list / l            # Show source code
list 10             # Show source around line 10
frame               # Show current function and line
info line           # Info about current source line
where / bt          # Backtrace (call stack)
```

---

## 6. Variables and State Inspection

```gdb
p x             # Print variable x
print *ptr          # Dereference pointer
info locals         # Show local variables
info args           # Show function arguments
```

Auto-display variable every stop:
```gdb
display x
undisplay
```

---

## 7. Stack and Frames

```gdb
bt                  # Backtrace
up                  # Move up stack frame
down                # Move down stack frame
frame 2             # Switch to frame #2
```

---

## 8. Signals and Execution Control

```gdb
info signals
handle SIGSEGV stop print
```

---

## 9. Enable TUI Mode

```gdb
tui enable
```

Or start GDB with:
```bash
gdb -tui ./a.out
```
