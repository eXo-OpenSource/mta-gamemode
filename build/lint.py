#!/bin/python
import time
import subprocess
from subprocess import call
import platform
import xml.etree.ElementTree as ET
import sys

start = time.time()
linter = "luac5.1"
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
print("Linting source...")

exit_status = 0
for file in files["server"]:
	process = subprocess.Popen([ linter, "-p", file ], stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
	output, error = process.communicate()
	formated_output = str(output)[(linter_length + 4):-3]
	if formated_output != "":
		exit_status = 1
		print("Error:\t" + formated_output)

for file in files["client"]:
	process = subprocess.Popen([ linter, "-p", file ], stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
	output, error = process.communicate()
	formated_output = str(output)[(linter_length + 4):-3]
	if formated_output != "":
		exit_status = 1
		print("Error:\t" + formated_output)


if exit_status != 0:
	sys.exit(exit_status)
else:
	print("Done. No errors found! (took %.2f seconds)" % (time.time() - start))
