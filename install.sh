#!/bin/bash

scriptdir="`pwd`"

cd
homedir="`pwd`"
cd "$scriptdir"

function exists() {
	if command -v "$1" >/dev/null 2>&1;
	then
		echo 1
	else
		echo 0
	fi
}

echo "Installing packages"
while read line           
do
	if ! [[ $line == \#* ]]; then  # if not comment line
		#statements
		package=(${line//\#/ })
		# echo "Installing $package"
		status=`dpkg-query -W -f='${Status}' ${package[0]} 2>/dev/null`

    	printf "%-20s " "$package"
    	if ! [[ $status == "install ok installed" ]]; then
    		`sudo apt-get install -qq -y $package 1>/dev/null`
    		printf "%s\n" "installed"
    	else
    		printf "%s\n" "ok"
    	fi
	fi
done < packages.txt 

# for each row in packages
# split by #, split by ,

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

if ! [ "$(exists calibre)" -eq 1 ]
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

# wget https://bitbucket.org/Skin36/gerix-wifi-cracker-pyqt4/downloads/gerix-wifi-cracker-master.rar
# unrar x gerix-wifi-cracker-master.rar
# rm gerix-wifi-cracker-master.rar

# YOUTUBE DOWNLOADER

if ! [ "$(exists ytdlmp3)" -eq 1 ]
then
	rm /usr/local/bin/ytdl
	ln -s $scriptdir/youtube-dl /usr/local/bin/ytdl 
	chmod u+x youtube-dl
	alias ytdlmp3='ytdl --extract-audio --audio-format "mp3"' #FIXME
fi

if ! [ "$(exists trash-put)" -eq 1 ]
then
	echo "Installing trash-cli" 
	sudo apt-get install trash-cli
fi

if [ -d "$homedir/.natim-tomate" ]; then
	echo "Updating tomate"
	cd ~/.natim-tomate
	git pull --quiet
	unlink /usr/local/bin/tomate
	ln -s "$homedir/.natim-tomate/tomate.py" /usr/local/bin/tomate
	cd $scriptdir
else
	echo "Installing tomate"
	git clone https://git.gitorious.org/~natim/tomate/natim-tomate.git "$homedir/.natim-tomate"
	ln -s "$homedir/.natim-tomate/tomate.py" /usr/local/bin/tomate
fi
