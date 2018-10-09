#!/usr/bin/python3
# put your demo script here

import sys
sideL = 10
i = 0
j = 0
while i < sideL:
    j = 0
    while j < sideL:
        sys.stdout.write("*")
        j = j + 1
    print()
    i = i + 1
