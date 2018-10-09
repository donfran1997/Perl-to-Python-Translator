#!/usr/bin/python3
# put your test script here
import re

line = "Cats are smarter than dogs";

s = re.search( r'(.*) are .*', line, re.M|re.I)

if s:
   print "searchObj.group() : ", s.group()
