#!/usr/bin/python
# Copyright 2008 Marcus D. Hanwell <marcus@cryos.org>
# Distributed under the terms of the GNU General Public License v2 or later
#
# Modified in 2012 by Mojca Miklavec <mmiklavec at users dot sourceforge dot net>
# to suit the requirements of AquaTerm project.
# bugfixes:
# - COLUMNS=200 to prevent git from shortening file paths
# - re.search('files changed', line) doesn't recognize '1 file changed'
# other changes:
# - slightly different output format
# - include tags for released versions

# How to make a release with ChangeLog including the latest changes?
#
# git add <all_the_files>
# git commit -m "Your commit message"
# git tag v<version>
# cd aquaterm
# ./gitlog2changelog.py
# git tag -d v<version>
# git reset --soft HEAD^
# git add ChangeLog
# git commit -c ORIG_HEAD
# git tag v<version>
import string, re, os

# Execute git log with the desired command line options.
fin = os.popen('COLUMNS=200 git log --summary --stat --no-merges --date=short --decorate=short', 'r')
# Create a ChangeLog file in the current directory.
fout = open('ChangeLog', 'w')

# Set up the loop variables in order to locate the blocks we want
authorFound = False
dateFound = False
messageFound = False
filesFound = False
message = ""
messageNL = False
files = ""
prevAuthorLine = ""

# The main part of the loop
for line in fin:
    # The commit line marks the start of a new commit object.
    if string.find(line, 'commit') >= 0:
        # Start all over again...
        authorFound = False
        dateFound = False
        messageFound = False
        messageNL = False
        message = ""
        filesFound = False
        files = ""
        # tagsFound = False
        tags = re.findall("tag: v([^,\)]*)[,\)]", line)
        continue
    # Match the author line and extract the part we want
    elif re.match('Author:', line) >=0:
        authorList = re.split(': ', line, 1)
        author = authorList[1]
        author = author[0:len(author)-1]
        authorFound = True
    # Match the date line
    elif re.match('Date:', line) >= 0:
        dateList = re.split(':   ', line, 1)
        date = dateList[1]
        date = date[0:len(date)-1]
        #date = line
        dateFound = True
    # The svn-id lines are ignored
    elif re.match('    git-svn-id:', line) >= 0:
        continue
    # The sign off line is ignored too
    elif re.search('Signed-off-by', line) >= 0:
        continue
    # Extract the actual commit message for this commit
    elif authorFound & dateFound & messageFound == False:
        # Find the commit message if we can
        if len(line) == 1:
            if messageNL:
                messageFound = True
            else:
                messageNL = True
        elif len(line) == 4:
            messageFound = True
        else:
            if len(message) == 0:
                message = message + line.strip()
            else:
                message = message + " " + line.strip()
    # If this line is hit all of the files have been stored for this commit
    elif re.search('files? changed', line) >= 0:
        filesFound = True
        continue
    # Collect the files for this commit. FIXME: Still need to add +/- to files
    elif authorFound & dateFound & messageFound:
        fileList = re.split(' \| ', line, 2)
        if re.search('English.lproj', fileList[0]) >=0:
            print line
            print fileList[0]
        if len(fileList) > 1:
            if len(files) > 0:
                files = files + ", " + fileList[0].strip()
            else:
                files = fileList[0].strip()
    # All of the parts of the commit have been found - write out the entry
    if authorFound & dateFound & messageFound & filesFound:
        # First the author line, only outputted if it is the first for that
        # author on this day
        authorLine = date + "  " + author
        if len(prevAuthorLine) == 0:
            fout.write(authorLine + "\n")
        elif authorLine == prevAuthorLine:
            pass
        else:
            fout.write("\n" + authorLine + "\n")

        # Assemble the actual commit message line(s) and limit the line length
        # to 80 characters.
        commitLine = "* " + files + ": " + message
        # width of \t should be considered 8
        maxLineLength = 78 - 8
        firstLine = True
        i = 0
        commit = ""
        for tag in tags:
            commit = commit + "\n\t* Version " + tag + " released.\n"
        while i < len(commitLine):
            if firstLine:
                commit = commit + "\n\t"
            else:
                commit = commit + "\n\t  "

            if len(commitLine) < i + maxLineLength:
                commit = commit + commitLine[i:len(commitLine)]
                break
            index = commitLine.rfind(' ', i, i+maxLineLength)
            if index > i:
                commit = commit + commitLine[i:index]
                i = index+1
            else:
                commit = commit + commitLine[i:maxLineLength]
                i = i+maxLineLength+1
            if firstLine:
                maxLineLength = maxLineLength - 2
                firstLine = False

        # Write out the commit line
        fout.write(commit + "\n")

        #Now reset all the variables ready for a new commit block.
        authorFound = False
        dateFound = False
        messageFound = False
        messageNL = False
        message = ""
        filesFound = False
        files = ""
        prevAuthorLine = authorLine

# Close the input and output lines now that we are finished.
fin.close()
fout.close()
