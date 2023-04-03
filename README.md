# Test task

- Створити окрему папку
- Створити 3 текстові файли в новій папці
- організувати зміну розширення файлів, через запит
- Організувати заповнення файлів будь-якими даними через введення з консолі
- Перевірити розміри файлів. Якщо розмір менше 5кб, збільшити розмір файлу до 5кб, випадковими текстовими даними
- Вивести кількість символів "а" у всіх файлах

## Input lines with >4096 chars

Interesting thing that I didn't know before..

The terminal is operating in a canonical or noncanonical mode with canonical being a default.
And in canonical mode each line of user input is truncated to 4095 characters (adding a newline as a 4096th character).

Quoting `termios(3)`:

> In canonical mode:
> 
>  * Input is made available line by line.  An input line is available when one of the line delimiters is typed (NL, EOL, EOL2; or EOF at the start of line).  Except in the  case  of  EOF,  the line delimiter is included in the buffer returned by read(2).
> 
>  * Line  editing  is  enabled (ERASE, KILL; and if the IEXTEN flag is set: WERASE, REPRINT, LNEXT).  A read(2) returns at most one line of input; if the read(2) requested fewer bytes than are available in the current line of input, then only as many bytes as requested are read, and the remaining characters will be available for a future read(2).
> 
>  * The maximum line length is 4096 chars (including the terminating newline character); lines longer than 4096 chars are truncated.  After 4095 characters, input processing  (e.g.,  ISIG  and ECHO*  processing)  continues,  but  any input data after 4095 characters up to (but not including) any terminating newline is discarded.  This ensures that the terminal can always receive more input until at least one line can be read.


### References

- [Two Styles of Input: Canonical or Not](https://www.gnu.org/software/libc/manual/html_mono/libc.html#Canonical-or-Not)
- [General Terminal Interface](https://pubs.opengroup.org/onlinepubs/9699919799/basedefs/V1_chap11.html)
- [Input from Python script](https://bugs.python.org/issue45511)
