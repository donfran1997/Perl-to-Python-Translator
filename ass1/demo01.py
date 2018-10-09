#!/usr/bin/python3
# put your demo script here


import sys

print("Enter age")

age = int(sys.stdin.readline())
if age < 12:
    print("child")
elif age < 19:
    print("teenager")
elif age < 60:
    print("worker")

