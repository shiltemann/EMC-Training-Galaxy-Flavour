from bioblend import galaxy
import os
import time


print "Starting upload of data libraries.."

#give galaxy some time to start up TODO: detect when Galaxy is up
time.sleep(30)

#TODO perform only if data libraries do not exist yet

# admin
gi = galaxy.GalaxyInstance(url='http://localhost:80', key='admin')

location="/home/galaxy/EMCtraining/datalibraries"
basedepth=location.count('/')
for root, dirs, files in os.walk(location):
    depth=root.count('/')-basedepth
    dirname=root[root.rfind("/")+1:]
    #dirname=dirname.translate(None,' ')
    if depth == 1:
        print('Creating data library: %s' % dirname )
        newlib = gi.libraries.create_library(dirname)
        print newlib
        libid=newlib['id']
        folderid=newlib['root_folder_id']
        print libid
    elif depth != 0:
        print('Creating subdirectory: %s' % dirname )
        newfolder = gi.libraries.create_folder(libid,dirname)
        folderid=newfolder[0]['id']
        print folderid
    for fname in files:
        #fname=fname.translate(None,' ')
        if depth > 0:
            print('Uploading file: %s (%s)' % (fname, root+'/'+fname))
            #gi.libraries.upload_from_galaxy_filesystem(libid,root+'/'+fname,folderid)
            gi.libraries.upload_file_from_local_path(libid,root+'/'+fname,folderid)
            #gi.libraries.upload_file_from_server(libid,os.path.relpath(root,location),folderid)
          
