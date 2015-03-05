#!/bin/python
import os
from os.path import join

fileCount = 0
scriptFileCount = 0
lineCount = 0

for root, dirs, files in os.walk("vrp"):
	for name in files:
		fileCount += 1
	
		if name[-3:] == "lua" or name[-3:] == "xml":
			scriptFileCount += 1
			file = open(join(root, name))
			
			for line in file:
				lineCount += 1
			
			file.close()

print("======= vRoleplay: Script statistics =======")
print("")
print("Number of files:         " + str(fileCount))
print("Number of scripts:       " + str(scriptFileCount))
print("Number of lines:         " + str(lineCount))
print("\n")

input("Press enter to exit")