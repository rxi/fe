@echo off

rem download this:
rem https://nuwen.net/mingw.html

gcc src/fe.c -DFE_STANDALONE -O3 -o fe -Wall -Wextra -std=c89 -pedantic
strip fe.exe
