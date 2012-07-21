#!/bin/bash

scriptdir="`pwd`"

# IMG2PDF
rm /usr/local/bin/img2pdf
ln -s $scriptdir/img2pdf.py /usr/local/bin/img2pdf
chmod u+x img2pdf.py

# YOUTUBE DOWNLOADER
rm /usr/local/bin/ytdl
ln -s $scriptdir/youtube-dl /usr/local/bin/ytdl 
chmod u+x youtube-dl
alias ytdlmp3='ytdl --extract-audio --audio-format "mp3"' #FIXME