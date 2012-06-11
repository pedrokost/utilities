#!/bin/bash
dev_url="http://www.sublimetext.com/dev";
file_regex="http://.*.rackcdn.com/.* x64.tar.bz2";
sublime_dir="/usr/lib/sublime-text-2/"
sublime_zip_name="subl.tar.bz2"
sublime_extracted_name="Sublime Text 2"

source_code=$(curl --silent $dev_url | head -n50);

if [[ source_code=~$file_regex ]]; then
  download_link=$(echo "$source_code" | grep -o "$file_regex")
  echo "Found download link: $download_link"
else
  echo "Failed to find download link"
fi
rm $sublime_zip_name
wget -O $sublime_zip_name "$download_link"

tar -jxf "$sublime_zip_name"
rm $sublime_zip_name

cp -r "$sublime_extracted_name/"* $sublime_dir
