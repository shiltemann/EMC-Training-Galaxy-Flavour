# Galaxy - EMC Training Galaxies
#
# VERSION       0.1
#
# Built on Galaxy Flavours by Bjorn Gruning
#
# Decide which training modules to include in your Galaxy Training Docker, and delete the others 
# (everything between START module and END module tags can be deleted if training module not required). 
# Then build your image.
#
# ~~~~~~~~~~~~~~~~~~~~~~~
#
#  Adding modules
#    1) DEPS: install any system requirements 
#    2) TOOLS: install necessary toolshed tools 
#           RUN install-repository "--url <toolshed_url> -o <tool owner> --name <tool_name> --panel-section-name <section name>" 
#    3) DATA LIBRARIES: copy any data libraries you wish to create to /home/galaxy/datalibraries
#       Any folder within this directory will become a datalibrary (with same name as folder), any further subfolder structure is kept intact within the library
#           ADD <local dir> /home/galaxy/datalibraries/
#    4) INDEXES: upload a bash script which installs your reference data to the /export/indexes/ folder and upload the .loc file to appropriate location. (/galaxy-central/tool-data)
#           --> place script in /home/galaxy/installscripts/
#           --> name must be like "install_reference_data_*.sh (all scripts matching this pattern will be executed upon first container start)
#           --> make sure script only runs if data not yet present 
#           --> using rsync to copy reference data from main Galaxy server is recommended where possible
#           --> recommended data structure convention: like main Galaxy server: 
#                  /export/indexes/<build>/<index name e.g. fasta,bowtie2,bwa,toolname>/
#
# ~~~~~~~~~~~~~~~~~~~~~~
#  
# Building and Starting the Docker container
#   --> docker build -t <image name> .  
#   --> docker run -d -v <local dir>:/export/ -p 8080:80 -p 8021:21 -p 9002:9002 -e "GALAXY_LOGGING=full" <image name>
#   --> exporting the /export/ folder is recommended so that reference data will not have to be redownloaded every time you start the container, 
#       and so that indexes may be shared across different containers.    
#

FROM bgruening/galaxy-stable

MAINTAINER Saskia Hiltemann, zazkia@gmail.com

ENV GALAXY_CONFIG_BRAND EMC-Training

WORKDIR /galaxy-central

# workaround for error "UTC FATAL:  could not access private key file "/etc/ssl/private/ssl-cert-snakeoil.key": Permission denied"
RUN mkdir /etc/ssl/private-copy; mv /etc/ssl/private/* /etc/ssl/private-copy/; rm -r /etc/ssl/private; mv /etc/ssl/private-copy /etc/ssl/private; chmod -R 0700 /etc/ssl/private; chown -R postgres /etc/ssl/private



###########################################
#    START Install Training Modules   
###########################################



#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#            PREREQUISITES 
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


# install rsync and bioblend
RUN apt-get -qq update && apt-get --no-install-recommends -y install rsync bedtools
RUN sudo pip install bioblend

# fix for OperationalError: (psycopg2.OperationalError) FATAL:  the database system is starting up
ADD install_repo_wrapper.sh /usr/bin/install-repository
RUN chmod a+x /usr/bin/install-repository



#len_file_path = tool-data/shared/ucsc/chrom


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#  START Training Module: Galaxy 101
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# TODO

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#  END of Training Module: Galaxy 101
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~




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
    "--url https://toolshed.g2.bx.psu.edu/ -o yhoogstrate --name edger_with_design_matrix --panel-section-name RNASeq" \
    "--url https://toolshed.g2.bx.psu.edu/ -o devteam --name tophat2 --panel-section-name RNASeq" 

    
## DATA LIBRARIES - copy data libraries to /home/galaxy/datalibraries/
ADD ./data-libraries/RNASeq_Basic /home/galaxy/EMCtraining/datalibraries/RNASeq_Basic


## INDEXES - configure reference data for tools TODO: fix revision in toolshed install or not hardcode in locfile location below
ADD ./install_reference_data_bowtie2_hg19_indexes.sh /home/galaxy/EMCtraining/installscripts/
ADD ./bowtie2_indices.loc /galaxy-central/tool-data/toolshed.g2.bx.psu.edu/repos/devteam/tophat2/6202ec8aab61/



#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#  END of Training Module: RNASeq Basic
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~




#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#  START Training Module: RNASeq Advanced
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# TODO

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#  END of Training Module: RNASeq Advanced
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


### configure Trackster
ADD ./install_reference_data_trackster_hg19.sh /home/galaxy/EMCtraining/installscripts/
ADD ./twobit.loc /galaxy-central/tool-data/
ENV GALAXY_CONFIG_LEN_FILE_PATH=tool-data/shared/ucsc/chrom
RUN mkdir /galaxy-central/tool-data/shared/ucsc/chrom/ 
ADD ./hg19.len /galaxy-central/tool-data/shared/ucsc/chrom/
ADD ./binaries/bedGraphToBigWig /usr/local/sbin/
ADD ./binaries/faToTwoBit /usr/local/sbin/
ADD ./binaries/wigToBigWig /usr/local/sbin/


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#            POSTREQUISITES 
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


# set allow_library_libary_path_paste to true for data library creation
ENV GALAXY_CONFIG_ALLOW_LIBRARY_PATH_PASTE=True
ENV GALAXY_CONFIG_LIBRARY_IMPORT_DIR=/home/galaxy/EMCtraining/datalibraries

# add scripts for creating data libraries and running all reference data install script
ADD ./libuploadgalaxy.py /home/galaxy/EMCtraining/installscripts/
ADD ./install_datalibraries_wrapper.sh /home/galaxy/EMCtraining/installscripts/
ADD ./run_all_references_install.sh /home/galaxy/EMCtraining/installscripts/

# add custom startup script (install reference data and start galaxy)
ADD ./startup.sh /usr/bin/startup
RUN chmod +x /usr/bin/startup

# 
# create the data libraries
#RUN bash /home/galaxy/EMCtraining/installscripts/install_datalibraries_wrapper.sh


###########################################
#    END Install Training Modules   
###########################################



# Expose port 80 (webserver), 21 (FTP server), 8800 (Proxy)
EXPOSE :80
EXPOSE :21
EXPOSE :8800

# Mark folders as imported from the host.
VOLUME ["/export/", "/data/", "/var/lib/docker"]

# Autostart script that is invoked during container start
CMD ["/usr/bin/startup"]

