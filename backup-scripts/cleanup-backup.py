import os
import shutil
import sys
import getopt
import re
import datetime
# backup directory
# Number of days old
# dryrun option

# Get a list of all tgz in directories
    # Root folder -> backup folder -> *.tar.gz

# In each directory:
    # Find the tgz that are older than nDays
    # Move into 'archive' directory

EPOCH = datetime.datetime.fromtimestamp(0)

def getFirstDayOfQuarter(year, quarter):
    month = ((quarter - 1) * 3) + 1
    date = datetime.datetime.strptime(str(year)+"_"+str(month), "%Y_%m")
    return date

# Parse the custom folder format for quarterly, monthly, weekly and return the
# time of the dir
def timeIncrementalDirectory ( dir_name ):
    lastDayOfPeriod = None

    if lastDayOfPeriod is None:
        # Quarterly
        regex = re.compile('^(\\d{4})_Q([1-4])$')
        match = regex.match(dir_name)
        if match:
            year = int(match.group(1))
            quarter = int(match.group(2))
            quarter += 1
            if quarter > 4:
                year += 1
                quarter = 1
           
            lastDayOfPeriod = getFirstDayOfQuarter(year, quarter) - datetime.timedelta(days=1)

    if lastDayOfPeriod is None:
        # Monthly
        regex = re.compile('^(\\d{4})_([0-1])\\d$')
        match = regex.match(dir_name)
        if match:
            year = int(match.group(1))
            month = int(match.group(2))
            month += 1
            if month > 12:
                year += 1
                month = 1
            lastDayOfPeriod = datetime.datetime.strptime(str(year)+"_"+str(month), "%Y_%m")

    if lastDayOfPeriod is None:
        # Weekly
        regex = re.compile('^(\\d{4})_W([0-5]\\d)$')
        match = regex.match(dir_name)
        if match:
            # Need to append the weekday in order for the parser to give a specific date
            # Start of the week is Sunday, so append "-0" and then parse
            lastDayOfPeriod = datetime.datetime.strptime(dir_name+"-0", "%Y_W%U-%w")
            lastDayOfPeriod += datetime.timedelta(days=6)
    
    return lastDayOfPeriod

# Function definition
def cleanDirectory ( dir_path, archive_output_path, timeDelta ):

    # Make sure that the file to list exists
    if os.path.exists(dir_path):
        if not os.listdir(dir_path):
            print ("Removing empty directory " + dir_path + "\n")
            os.rmdir(dir_path)
        else:
            # calculate what time (in seconds) to use as a cutoff for moving files
            currentDate = datetime.datetime.now()
            dateCutoff = currentDate - timeDelta

            print ("Searching " + dir_path + " for backups older than " + str(timeDelta) + "\n")
            print ("(Created before " + str(dateCutoff) + ")\n")

            filesInDir = os.listdir(dir_path)

            filesOlderThanCutoff = []
            for file in filesInDir:
                file_full_path = os.path.join(dir_path, file)

                if os.path.isfile(file_full_path):
                    fileModDate = datetime.datetime.fromtimestamp(os.path.getmtime(os.path.join(dir_path,file)))
                    if fileModDate < dateCutoff:
                        filesOlderThanCutoff.append(file)
                elif os.path.isdir(file_full_path):
                    dirCreation = timeIncrementalDirectory(file)
                    if dirCreation is None:
                        print "ERROR: Unable to parse date of directory: \"" + file_full_path + "\"\n"
                    elif dirCreation < dateCutoff:
                        filesOlderThanCutoff.append(file)
                else:
                    print ("ERROR: " + str(file_full_path) + " is somehow neither a file or directory\n")

            print(filesOlderThanCutoff)

            if filesOlderThanCutoff:
                #excludeDir = os.path.join(dir_path, "exclude")
                if not os.path.exists(archive_output_path):
                    os.makedirs(archive_output_path)

                for archiveFile in filesOlderThanCutoff:
                    srcFile = os.path.join(dir_path, archiveFile)
                    dstFile = os.path.join(archive_output_path, archiveFile)
                    shutil.move(srcFile, dstFile)
                    print("Moved \"" + srcFile + "\" to archive folder")

    else:
        print ("ERROR: The provided directory to cleanDirectory() \"" + dir_path + "\" does not exist")


# MAIN
# argv[0] = path to backup folder
# argv[1] = path to (output) archive folder
# argv[2] = number of days old before archiving

if len(sys.argv) != 4:
    print ("ERROR: only three arguments are allowed")
    exit(-1)

dir_path = sys.argv[1]
archive_path = sys.argv[2]
days_old_to_archive = sys.argv[3]

if not os.path.exists(dir_path):
    print ("ERROR: directory path \"" + dir_path + "\" does not exist")
    exit(-1)

if not os.path.exists(archive_path):
    print ("ERROR: directory path \"" + archive_path + "\" does not exist")
    exit(-1)

try:
    nDaysCutoff = int(days_old_to_archive)
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
    cleanDirectory(os.path.join(dir_path, dir), os.path.join(archive_path, dir), datetime.timedelta(days=nDaysCutoff))
