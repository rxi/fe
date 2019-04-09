#!/bin/bash
gcc src/fe.c -DFE_STANDALONE -O3 -o fe -Wall -Wextra -std=c89 -pedantic
