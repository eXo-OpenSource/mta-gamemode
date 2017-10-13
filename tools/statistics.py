#!/usr/bin/env python3
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

			try:
				lineCount += file.read().count("\n") + 1

			except Exception as e:
				print("could not read " + join(root, name))
				print(e)
				print("")

			file.close()

print("")
print("======= vRoleplay: Script statistics =======")
print("")
print("Number of files:         " + str(fileCount))
print("Number of scripts:       " + str(scriptFileCount))
print("Number of lines:         " + str(lineCount))
print("")
print("============================================")
print("\n")

input("Press enter to exit")
