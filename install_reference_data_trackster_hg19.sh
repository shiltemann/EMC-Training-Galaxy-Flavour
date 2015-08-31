# Should run on container startup
# Will download bowtie2_index to /export/indexes/hg19/bowtie2_index/ if not yet present
#
# If /export/ is mounted to location on guest OS, it will not have to do this every time container starts

# rsync -avzP rsync://datacache.g2.bx.psu.edu:/indexes/hg19/bowtie2_index /export/reference/hg19/bowtie2_index/
# 

installdir="/export/indexes/hg19/seq/"
installbase="/export/indexes/hg19/seq/"


# install: twobit files, chrom len files

# if directory does not yet exist, get data from Galaxy Main's rsync server
echo "Attempting to install trackster indexes"
if [ ! -d  $installdir ] 
then
  
  #install twobit files
  mkdir -m a+rwx -p $installbase
  rsync -avzPL rsync://datacache.g2.bx.psu.edu:/indexes/hg19/seq/hg19.2bit $installbase
  
  #install tools
  #cd /usr/local/sbin 
  #wget http://hgdownload.cse.ucsc.edu/admin/exe/linux.x86_64/wigToBigWig
  #wget http://hgdownload.cse.ucsc.edu/admin/exe/linux.x86_64/bedGraphToBigWig
  #wget http://hgdownload.cse.ucsc.edu/admin/exe/linux.x86_64/faToTwoBit
  #chmod a+x wigToBigWig faToTwoBit bedGraphToBigWig
  
else
    echo "indexes already installed ($installdir exists), skipping"
fi


