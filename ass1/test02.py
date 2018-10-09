#!/usr/bin/python3
# script here
num = 407
if num > 1:
   for i in range(2,num):
       if (num % i) == 0:
           print(num,"is not a prime number")
           print(i,"times",num//i,"is",num)
           break
   else:
       print(num,"is a prime number")
       
else:
   print(num,"is not a prime number")
