# Utilities

## update-sublime.sh
A bash script that downloads and installs the latest Sublime text dev version.

* make it executable
* symlink to /usr/local/bin (rename to update_sublime)
* execute using sudo update_sublime

## img2pdf.py
https://github.com/josch/img2pdf

## Youtube downloader
A terminal youtube downloader, which downloads any available format.
https://gist.github.com/3148848

- Pick which video format you want to download.. (use any YT video link)
./youtube-dl -s -F http://www.youtube.com/watch?v=vT1KmTQ-1Os
- Extract audio track from video
./youtube-dl -f 5 --extract-audio http://www.youtube.com/watch?v=vT1KmTQ-1O