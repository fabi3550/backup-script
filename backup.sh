#!/bin/bash

logmessage() {
    echo $(date +"%H:%M:%S"): $1
}

# read input parameters
while [ "$1" != '' ]
    do
        [ "$1" == --scp ] && scp_path="$2" && shift && shift
        [ "$1" == --file ] && target_filename="$2" && shift && shift
        [ "$1" == --pgp ] && pgp_key="$2" && shift && shift
        [ "$1" == --list ] && listfile="$2" && shift && shift
    done

# define backup filename
backup_filename=$(date +"%Y_%m_%d")_$HOSTNAME.tar.gz

#create a tar file by parameterfile
logmessage "create a tar file"
tar -cjf $HOME/$backup_filename -T $listfile

#encrypt with defined pgp key
if [ -n "$pgp_key" ]
then
    logmessage "encrypt the tar file"
    gpg2 --encrypt --recipient $pgp_key $backup_filename
    logmessage "deleting original tar file"
    rm $backup_filename
    backup_filename=$backup_filename.gpg
fi

if [ -n "$scp_path" ]
then
    logmessage "transfer backup via scp to $scp_path"
    scp $backup_filename $scp_path
fi

if [ -n "$target_filename" ]
then
    logmessage "copy backup to $target_filename"
    scp $backup_filename $target_filename
fi

logmessage "delete temporary backup file"
rm $backup_filename
