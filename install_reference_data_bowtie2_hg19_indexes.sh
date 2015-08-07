# Should run on container startup
# Will download bowtie2_index to /export/indexes/hg19/bowtie2_index/ if not yet present
#
# If /export/ is mounted to location on guest OS, it will not have to do this every time container starts

# rsync -avzP rsync://datacache.g2.bx.psu.edu:/indexes/hg19/bowtie2_index /export/reference/hg19/bowtie2_index/
# 

installdir="/export/indexes/hg19/bowtie2_index/"
installbase="/export/indexes/hg19/"
# if directory does not yet exist, get data from Galaxy Main's rsync server

echo "Attempting to install bowtie2 indexes"
if [ ! -d  $installdir ] 
then
  mkdir -m a+rwx -p $installbase
  rsync -avzPL rsync://datacache.g2.bx.psu.edu:/indexes/hg19/bowtie2_index $installbase
else
    echo "indexes already installed ($installdir exists), skipping"
fi


