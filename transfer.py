# read lines 
import os 

with open('input.txt', 'r') as input: 
    lines = input.readlines() 
    print (len(lines)) 
    print (lines[0])
    for l in lines: 
        l = '.' + l 
        l = l.replace('/*', '//')
        l = l.replace('*/', '')
        print (l, end="")
