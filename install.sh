#!/bin/bash

scriptdir="`pwd`"

function exists() {
	if command -v "$1" >/dev/null 2>&1;
	then
		echo 1
	else
		echo 0
	fi
}

# if [ "$(exists rm)" -eq 1 ]
# then

# fi

echo "initializing submodules"
git submodule init
git submodule update

if ! [ "$(exists fasd)" -eq 1 ]
then
	echo "Setting up FASD - a command-line productivity booster"
	cd fasd
	make install
	cd ..
fi

if ! [ "$(exists rm)" -eq 1 ]
then
	echo "Installing Calibre"
	sudo python -c "import sys; py3 = sys.version_info[0] > 2; u = __import__('urllib.request' if py3 else 'urllib', fromlist=1); exec(u.urlopen('http://status.calibre-ebook.com/linux_installer').read()); main()"
fi

# IMG2PDF
if ! [ "$(exists img2pdf)" -eq 1 ]
then
	rm /usr/local/bin/img2pdf
	ln -s $scriptdir/img2pdf.py /usr/local/bin/img2pdf
	chmod u+x img2pdf.py
fi


# YOUTUBE DOWNLOADER

if ! [ "$(exists img2pdf)" -eq 1 ]
then
	rm /usr/local/bin/img2pdf
	ln -s $scriptdir/img2pdf.py /usr/local/bin/img2pdf
	chmod u+x img2pdf.py
fi

# wget https://bitbucket.org/Skin36/gerix-wifi-cracker-pyqt4/downloads/gerix-wifi-cracker-master.rar
# unrar x gerix-wifi-cracker-master.rar
# rm gerix-wifi-cracker-master.rar


if ! [ "$(exists ytdlmp3)" -eq 1 ]
then
	rm /usr/local/bin/ytdl
	ln -s $scriptdir/youtube-dl /usr/local/bin/ytdl 
	chmod u+x youtube-dl
	alias ytdlmp3='ytdl --extract-audio --audio-format "mp3"' #FIXME
fi

echo "Installing trash-cli" 
sudo apt-get install trash-cli

