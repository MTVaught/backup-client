import os
import shutil
import time
import sys
import getopt
import configparser
# backup directory
# Number of days old
# dryrun option

# Get a list of all tgz in directories
    # Root folder -> backup folder -> *.tar.gz

# In each directory:
    # Find the tgz that are older than nDays
    # Move into 'exclude' directory

# Function definition
def cleanDirectory ( dir_path, exclude_output_path, nDays ):

    # Make sure that the file to list exists
    if os.path.exists(dir_path):
        if not os.listdir(dir_path):
            print ("Removing empty directory " + dir_path + "\n")
            os.rmdir(dir_path)
        else:
            # calculate what time (in seconds) to use as a cutoff for moving files
            timeOffset = nDays * 24 * 60 * 60
            timeCurrent = time.time()
            timeCutoff = timeCurrent - timeOffset
            print ("Searching " + dir_path + " for files older than " + str(nDays) + " days")
            #print ("good path")
            filesInDir = os.listdir(dir_path)

            filesOlderThanCutoff = []
            for file in filesInDir:
                fileModTime = os.path.getmtime(os.path.join(dir_path,file))
                if fileModTime < timeCutoff:
                    filesOlderThanCutoff.append(file)

            #print(filesOlderThanCutoff)

            if filesOlderThanCutoff:
                #excludeDir = os.path.join(dir_path, "exclude")
                if not os.path.exists(exclude_output_path):
                    os.makedirs(exclude_output_path)

                for excludeFile in filesOlderThanCutoff:
                    srcFile = os.path.join(dir_path, excludeFile)
                    dstFile = os.path.join(exclude_output_path, excludeFile)
                    shutil.move(srcFile, dstFile)
                    print("Moved \"" + srcFile + "\" to exclude folder")

    else:
        print ("ERROR: The provided directory to cleanDirectory() \"" + dir_path + "\" does not exist")


# MAIN
# argv[0] = path to backup folder
# argv[1] = path to (output) excludes folder
# argv[2] = path to config file

if len(sys.argv) != 4:
    print ("ERROR: only three arguments are allowed")
    exit(-1)

dir_path = sys.argv[1]
exclude_path = sys.argv[2]
config_path = sys.argv[3]

if not os.path.exists(dir_path):
    print ("ERROR: directory path \"" + dir_path + "\" does not exist")
    exit(-1)

if not os.path.exists(exclude_path):
    print ("ERROR: directory path \"" + exclude_path + "\" does not exist")
    exit(-1)

if not os.path.isfile(config_path):
    print ("ERROR: config file \"" + config_path + "\" does not exist")
    exit(-1)

config = configparser.ConfigParser()
config.read(config_path)
nDaysCutoff = config['CLEANUP']['days']

try:
    nDaysCutoff = int(nDaysCutoff)
except ValueError:
    print ("ERROR: cutoff must be an integer (number of days)")
    exit(-1)

print("Running cleanup script in \"" + dir_path + "\"")
print("Cleaning up files older than " + str(nDaysCutoff)  + " days")

filesInDir = os.listdir(dir_path)

onlyfiles = [f for f in filesInDir if os.path.isfile(os.path.join(dir_path, f))]
onlydirs = list(set(filesInDir) - set(onlyfiles))

#print (onlyfiles)
#print (onlydirs)

for file in onlyfiles:
    print ("WARNING: \"" + file + "\" is not a directory. Ignoring.")

#for dir in onlydirs:
#    cleanDirectory
#
for dir in onlydirs:
    cleanDirectory(os.path.join(dir_path, dir), os.path.join(exclude_path, dir), nDaysCutoff)
