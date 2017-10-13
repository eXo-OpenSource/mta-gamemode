#!/usr/bin/env python3
import re
import os
from os.path import join
from os.path import basename

GTA_PATH = r"D:\Program Files (x86)\Rockstar Games\GTA San Andreas\data\maps"

def getObjectIDList(fileHandle):
    objectList = []

    for match in re.findall("(\d*), (.*?),.*\n", fileHandle.read()):
        objectList.append(match)

    return objectList

def getLODsFromObjectList(objectList):
    objectLodPairs = []
    lodCount = 0
    lodMatches = 0

    # First, get a list of all LOD objects
    lodObjects = []
    for item in objectList:
        if item[1][:3] == "LOD":
            lodCount = lodCount + 1
            lodObjects.append(item)

    # Next, find the related non-LOD model ID
    for item in objectList: # there are better ways instead of 2 nested for loops, but I'm too lazy to further think about that
        for lodItem in lodObjects:
            if item[1] == lodItem[1][3:]:
                lodMatches = lodMatches + 1
                objectLodPairs.append([item[0], lodItem[0]])
                break # If we found one, we can proceed with the next LOD

    # Check if LOD count matches found LOD pairs (mainly for debugging purposes)
    #print("LOD count matches: " + str(lodCount) + " vs " + str(lodMatches))

    return objectLodPairs

global lodCounter
lodCounter = 0
for root, dirs, files in os.walk(GTA_PATH):
    for name in files:
        if name[-3:] == "ide":
            # Scan file for LODs
            with open(join(root, name)) as fileHandle:
                objectList = getObjectIDList(fileHandle)
                lodObjects = getLODsFromObjectList(objectList)

                lodCounter = lodCounter + len(lodObjects)

                # Print results to the console
                for item in lodObjects:
                    print("[" + item[0] + "] = " + item[1] + ",")

# Some statistics
print("LOD count: " + str(lodCounter))
