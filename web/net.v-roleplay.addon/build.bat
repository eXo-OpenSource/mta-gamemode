rm -rf files.tar
rm -rf templates.tar
rm -rf net.v-roleplay.addon.tar

tar -Rcf files.tar -C files lib
tar -Rcf templates.tar -C templates blog.tpl

tar -cf net.v-roleplay.addon.tar templates.tar files.tar package.xml xml languages