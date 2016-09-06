# #!/bin/bash

# usage:
# bash cryptor.sh <PASSWORD>

files_folder="files"
tar_filename="files.tar"
files_encoded="files.enc"

# check if folder or encrypted file exists
if [ -d "$files_folder" ]; then
  echo "encryption mode";
  MODE="enc"
elif [ -f "$files_encoded" ]; then
  echo "decryption mode";
  MODE="dec"
else
  echo "no files folder or encrypted file, exiting"; exit 1
fi

# if no password is provided, ask for one
if [ ! "$1" ]; then
  # if encrypting, ask for confirmation
  if [ "$MODE" = "enc" ]; then
    while true; do
      read -s -p "Password: " PASSWORD
      echo
      read -s -p "Password (again): " PASSWORD2
      echo
      [ "$PASSWORD" = "$PASSWORD2" ] && break
      echo "Please try again"
    done
  else
    read -s -p "Password: " PASSWORD
  fi
else
  PASSWORD="$1"
fi

if [[ $MODE == "enc" ]]; then
  # archive the folder
  tar -cf $tar_filename $files_folder

  # encrypt
  if openssl enc -aes256 -a -in $tar_filename -out $files_encoded -k $PASSWORD ; then
    echo "encryption succeeded"
    rm -rf $files_folder $tar_filename
    # push to GH with encrypted files
    DATE="sync-"`date +%Y-%m-%d`
    git add $files_encoded && git commit --amend -m $DATE && git push origin gh-sync --force
  else
    echo "error in encryption"
  fi
else
  # decrypt
  if openssl enc -aes256 -a -d -in $files_encoded -out $tar_filename -k $PASSWORD ; then
    echo "decryption succeeded"
    tar -xvf $tar_filename
    rm -rf $files_encoded $tar_filename
  else
    echo "error in decryption"
    rm -rf $tar_filename
  fi
fi
