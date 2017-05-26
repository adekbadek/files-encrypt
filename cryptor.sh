#!/bin/bash

# usage:
# bash cryptor.sh <PASSWORD>

files_folder="files"
tar_filename="files.tar"
files_encoded="files.enc"

# if no password is provided, ask for one
if [ ! "$1" ]; then
  echo 'pass:'
  read -s password
else
  password="$1"
fi

# check if folder or encrypted file exists
if [ -d "$files_folder" ]; then
  echo "encryption mode";
  mode="enc"
elif [ -f "$files_encoded" ]; then
  echo "decryption mode";
  mode="dec"
else
  echo "no files folder or encrypted file, exiting"; exit 1
fi

if [[ $mode == "enc" ]]; then
  # archive the folder
  tar -cf $tar_filename $files_folder

  # encrypt
  if openssl enc -aes256 -a -in $tar_filename -out $files_encoded -k $password ; then
    echo "encryption succeeded"
    rm -rf $files_folder $tar_filename
  else
    echo "error in encryption"
  fi
else
  # decrypt
  if openssl enc -aes256 -a -d -in $files_encoded -out $tar_filename -k $password ; then
    echo "decryption succeeded"
    tar -xvf $tar_filename
    rm -rf $files_encoded $tar_filename
  else
    echo "error in decryption"
    rm -rf $tar_filename
  fi
fi
