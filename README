EMC Training Galaxy Flavour
===========================

Based on Björn Grüning's Galaxy Docker (https://github.com/bgruening/docker-galaxy-stable)

Usage
=====
Decide which training modules to include in your Galaxy Training Docker, and delete the others from the Dockerfile
(everything between START module and END module tags can be deleted if the training module not required). 

Then build your image.

```
docker build -t <image name> . 
```
And start it

```
docker run -d -v <local dir>:/export/ -p 8080:80 -p 8021:21 -p 9002:9002 -e "GALAXY_LOGGING=full" <image name>
```

Upon container start, all reference-data install scripts are run. If reference data not yet present, it will be downloaded (may take a long time). Exporting the /export/ folder is recommended so that reference data will only be downloaded the first time, and so that indexes may be shared across different containers.



Adding Training Modules
=======================
Configure:

```
1) DEPS: install any system requirements 
2) TOOLS: install necessary toolshed tools 
      RUN install-repository "--url <toolshed_url> -o <tool owner> --name <tool_name> --panel-section-name <section name>" 
3) DATA LIBRARIES: copy any data libraries you wish to create to /home/galaxy/datalibraries
   Any folder within this directory will become a datalibrary (with same name as folder), any further subfolder structure is kept intact within the library
      ADD <local dir> /home/galaxy/datalibraries/
4) INDEXES: upload a bash script which installs your reference data to the /export/indexes/ folder and upload the .loc file to appropriate location. (/galaxy-central/tool-data/<toolshed>/repos/<owner>/<revision>/)
           --> place script in /home/galaxy/installscripts/
           --> name must be like "install_reference_data_*.sh (all scripts matching this pattern will be executed upon first container start)
           --> make sure script only runs if data not yet present 
           --> using rsync to copy reference data from main Galaxy server is recommended where possible
           --> recommended data structure convention: like main Galaxy server: 
                  /export/indexes/<build>/<index name e.g. fasta,bowtie2,bwa,toolname>/


 Building and Starting the Docker container
   --> docker build -t <image name> .  
   --> docker run -d -v <local dir>:/export/ -p 8080:80 -p 8021:21 -p 9002:9002 -e "GALAXY_LOGGING=full" <image name>
   --> exporting the /export/ folder is recommended so that reference data will not have to be redownloaded every time you start the container, 
       and so that indexes may be shared across different containers.    

```

Example: Basic RNASeq Training Module in Dockerfile

```
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#  START Training Module: RNASeq Basic
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

## DEPS - install system requirements
# None


## TOOLS - install from toolshed
RUN install-repository \
    "--url https://toolshed.g2.bx.psu.edu/ -o devteam --name fastq_groomer --panel-section-name RNASeq" \
    "--url https://toolshed.g2.bx.psu.edu/ -o devteam --name fastqc --panel-section-name RNASeq" \
    "--url https://toolshed.g2.bx.psu.edu/ -o nilesh --name sickle --panel-section-name RNASeq" \
    "--url https://toolshed.g2.bx.psu.edu/ -o yhoogstrate --name featurecounts --panel-section-name RNASeq" \
    "--url https://toolshed.g2.bx.psu.edu/ -o iuc --name rgrnastar --panel-section-name RNASeq" \
    "--url https://testtoolshed.g2.bx.psu.edu/ -o yhoogstrate --name edger_with_design_matrix --panel-section-name RNASeq" \
    "--url https://toolshed.g2.bx.psu.edu/ -o devteam --name tophat2 --panel-section-name RNASeq" 

    
## DATA LIBRARIES - copy data libraries to /home/galaxy/datalibraries/
ADD ./data-libraries/RNASeq_Basic /home/galaxy/EMCtraining/datalibraries/RNASeq_Basic


## INDEXES - configure reference data for tools
ADD ./install_reference_data_bowtie2_hg19_indexes.sh /home/galaxy/EMCtraining/installscripts/
ADD ./bowtie2_indices.loc /galaxy-central/tool-data/


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#  END of Training Module: RNASeq Basic
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
```
