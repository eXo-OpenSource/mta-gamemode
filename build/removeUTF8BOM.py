#!/bin/python
import os

numBOMFiles = 0
for root, subdirs, files in os.walk("vrp/"):
	for filename in files:
		filePath = os.path.join(root, filename)

		if filePath[-4:] == ".lua":
			try:
				file = open(filePath, "r+b")

				# Is there a BOM?
				if file.read(3) == b"\xEF\xBB\xBF":
					numBOMFiles = numBOMFiles + 1

					content = file.read()
					file.close()

					with open(filePath, "wb") as writeFile:
						writeFile.write(content)

			finally:
				file.close()

print("Removed BOM of " + str(numBOMFiles) + " script files!")
