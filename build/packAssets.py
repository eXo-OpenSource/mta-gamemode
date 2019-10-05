import os
import xml.etree.ElementTree as ET
import shutil
import time
import hashlib
import tarfile
from pathlib import Path

# Util functions
def find_between(s, first, last):
    try:
        start = s.index( first ) + len( first )
        end = s.index( last, start )
        return s[start:end]
    except ValueError:
        return ""

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
os.mkdir(outdir+"/archives")
os.mkdir(outdir+"/files")

def file_size(fname):
    import os
    statinfo = os.stat(fname)
    return statinfo.st_size
		
# Copy files
print("Copying required files...")

main_tree = ET.parse(rootdir + "meta.xml")
main_root = main_tree.getroot()
asset_root = ET.Element("files")
archives = {}
files = {}

for child in main_root.findall("vrpfile"):

	# get filename
    filename = child.attrib["src"]

	# get dirname
    dirname = find_between(filename, "files/", "/")
    if not dirname in archives:
        archives[dirname] = tarfile.open(outdir + "/archives/%s.tar" % dirname, 'w')
        files[archives[dirname]] = {}

	# add the files to the archive
    archives[dirname].add(rootdir+filename, arcname=(rootdir+filename)[4:])

    Path(outdir + os.path.dirname(filename)).mkdir(parents=True, exist_ok=True)
    shutil.copy2(rootdir + filename, outdir + filename)

    files[archives[dirname]][len(files[archives[dirname]])+1] = filename

for index, archive in archives.items():
    # close the archive
    archive.close()

    element = ET.SubElement(asset_root, "archive", name="%s.tar" % index,
	                        path="archives/%s.tar" % index,
                            target_path="cache/%s.tar" % index,
		                   	hash=md5(outdir+"archives/%s.tar" % index))
    for _, file in files[archive].items():
        ET.SubElement(element, "file", path=file, target_path=file, hash=md5(rootdir+file), size=file_size(rootdir+file))


asset_tree = ET.ElementTree(asset_root)
asset_tree.write(outdir+"index.xml")

# Pack assets
print("Done. (took %.2f seconds)" % (time.time() - start))
