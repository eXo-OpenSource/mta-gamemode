#!/bin/python
import time
import subprocess
from subprocess import call
import platform
import xml.etree.ElementTree as ET
import sys

start = time.time()
linter = "luac"
linter_length = 4
if platform.system() == "Windows":
	linter = "tools/luac.exe"
	linter_length = 14
rootdir = "vrp/"


# At first remove UTF8BOM
if platform.system() == "Windows":
	call(["py", "-3", "build/removeUTF8BOM.py"])
else:
	call(["python3", "build/removeUTF8BOM.py"])


# Get all files and lint them
print("Getting all files...")

files = {}
files["server"] = []
files["client"] = []

tree = ET.parse(rootdir + "meta.xml")
root = tree.getroot()

for child in root.findall("script"):
	if child.attrib["type"] == "server":
		files["server"].append(rootdir+child.attrib["src"])
	if child.attrib["type"] == "client":
		files["client"].append(rootdir+child.attrib["src"])
	if child.attrib["type"] == "shared":
		files["server"].append(rootdir+child.attrib["src"])
		files["client"].append(rootdir+child.attrib["src"])


# Call the linter
print("Linting source... (Note: Only first the error gets displayed!)") # find alternative to luac -p

serverCall = [ linter, "-p" ]
serverCall.extend(files["server"])
process = subprocess.Popen(serverCall, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
output, error = process.communicate()
formated_output = str(output)[(linter_length + 4):]
if formated_output != "":
	sys.exit(Exception("Server error occured:\t"+ formated_output))

clientCall = [ linter, "-p" ]
clientCall.extend(files["client"])
process = subprocess.Popen(clientCall, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
output, error = process.communicate()
formated_output = str(output)[(linter_length + 4):]
if formated_output != "":
	sys.exit(Exception("Client error occured:\t"+ formated_output))

print("Done. No errors found! (took %.2f seconds)" % (time.time() - start))
