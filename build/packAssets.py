import os
import xml.etree.ElementTree as ET
import subprocess
import shutil
import time
import hashlib

def md5(fname):
    hash_md5 = hashlib.md5()
    with open(fname, "rb") as f:
        for chunk in iter(lambda: f.read(4096), b""):
            hash_md5.update(chunk)
    return hash_md5.hexdigest()

start = time.time()
# Dir Settings
rootdir = "vrp/"
outdir = "vrp_assets/"

# Remove existing vrp_assets dir
print("Creating assets structure...")

def rm_r(path):
    if os.path.isdir(path):
        shutil.rmtree(path)
    elif os.path.exists(path):
        os.remove(path)
rm_r(outdir)
os.mkdir(outdir)
os.mkdir(outdir+"/packages")

# Copy files
print("Copying required files...")

main_tree = ET.parse(rootdir + "meta.xml")
main_root = main_tree.getroot()
asset_root = ET.Element("files")
files = []

for child in main_root.findall("vrpfile"):
	# copy the files
	filename = child.attrib["src"]
	files.append(rootdir+filename)
	print(rootdir+filename)

serverCall = [ "lua", "build/lua/gen_pack/init.lua" ]
serverCall.extend(files)
process = subprocess.Popen(serverCall, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
output, error = process.communicate()
packageCount = int(output)
print("Generated %i packages!" % packageCount)
for i in range(0, packageCount):
	i = i + 1
	ET.SubElement(asset_root, "file", name="Package-%i.data" % i, path="packages/%i.data" % i, target_path="cache/%i.data" % i, hash=md5(outdir+"packages/%i.data" % i))

asset_tree = ET.ElementTree(asset_root)
asset_tree.write(outdir+"index.xml")

# Pack assets
print("Done. (took %.2f seconds)" % (time.time() - start))
