rm -rf files.tar
rm -rf net.v-roleplay.sync.tar

tar -Rcf files.tar -C files lib

tar -cf net.v-roleplay.sync.tar files.tar package.xml xml languages