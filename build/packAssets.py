import os
import xml.etree.ElementTree as ET
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

# Copy files
print("Copying required files...")

main_tree = ET.parse(rootdir + "meta.xml")
main_root = main_tree.getroot()
asset_root = ET.Element("files")

for child in main_root.findall("vrpfile"):
	# copy the files
	filename = child.attrib["src"]
	assetpath = filename[6:]
	if not os.path.exists(outdir+os.path.dirname(assetpath)):
		os.makedirs(outdir+os.path.dirname(assetpath))

	shutil.copyfile(rootdir+filename, outdir+assetpath)

	# write file index
	ET.SubElement(asset_root, "file", name=os.path.basename(filename), path=assetpath, target_path=filename, hash=md5(outdir+assetpath))


asset_tree = ET.ElementTree(asset_root)
asset_tree.write(outdir+"index.xml")

# Pack assets
print("Done. (took %.2f seconds)" % (time.time() - start))
