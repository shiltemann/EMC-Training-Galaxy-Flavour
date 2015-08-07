# Will run all scripts named like "install_reference_data_*.sh"
#
# Each script should install necessary references to /export/ folder. 
#  -> recommend using rsync from main galaxy where possible
#  -> e.g. rsync -avzP rsync://datacache.g2.bx.psu.edu:/indexes/hg19/bowtie2_index /export/indexes/hg19/bowtie2_index/
# 
# Follow directory structure as in main Galaxy (rsync --list-only rsync://datacache.g2.bx.psu.edu:/)
#
# /export/indexes/<dbkey>/<name>
#
# /export/indexes/hg19/bowtie2_index
# /export/indexes/hg18/picard_index
#  ..
#
# When /export/folder is mounted to a host location, different containers can share reference data and
# installation will only occurr on first start of image
#
installscriptdir="/home/galaxy/EMCtraining/installscripts/"
for installscript in ${installscriptdir}/install_reference_data_*.sh
do
    echo "running reference data install script: $installscript"
    bash $installscript
done
