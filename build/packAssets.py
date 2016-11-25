import os
import xml.etree.ElementTree as ET
import shutil

# Dir Settings
rootdir = "vrp/"
outdir = "vrp_assets/"

# Remove existing vrp_assets dir
os.chdir("..")
def rm_r(path):
    if os.path.isdir(path):
        shutil.rmtree(path)
    elif os.path.exists(path):
        os.remove(path)
rm_r(outdir)
os.mkdir(outdir)

# Copy files
main_tree = ET.parse(rootdir + "meta.xml")
main_root = main_tree.getroot()
asset_root = ET.Element("files")

for child in main_root.findall("http_asset"):
	# copy the files
	filename = child.attrib["src"]
	assetpath = filename[6:]
	if not os.path.exists(outdir+os.path.dirname(assetpath)):
		os.makedirs(outdir+os.path.dirname(assetpath))

	shutil.copyfile(rootdir+filename, outdir+assetpath)

	# write file index
	ET.SubElement(asset_root, "file", name=os.path.basename(filename), path=assetpath, target_path=filename)


asset_tree = ET.ElementTree(asset_root)
asset_tree.write(outdir+"index.xml")

# Pack assets
