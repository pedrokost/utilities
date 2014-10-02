#!/bin/bash
shopt -s extglob # turn it on (for whitespace removal)

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

function empty_or_comment() {
	line="${1##*( )}"  # trim leading whitespace
	if [ -z "$line" ];then
		return 0 # skip if empty space
	fi
	if [[ $line == \#* ]]; then
		return 0 # if not comment line
	fi
	return 1
}


echo "Adding PPAs"
while read line           
do
	empty_or_comment "$line" && continue

	ppa=(${line//\#/ })
	printf "%-50s" "$ppa"
	add-apt-repository -y $ppa &> /dev/null && printf "%s\n" "ok" || printf "%s\n" "fail"
done < ppas.txt

printf "%-50s" "Updating packages (can take a while)"
apt-get update  &> /dev/null && printf "%s\n" "ok" || printf "%s\n" "fail"

echo "Installing packages"
while read line           
do
	empty_or_comment "$line" && continue
 
	package=(${line//\#/ })
	status=`dpkg-query -W -f='${Status}' ${package[0]} 2>/dev/null`

	printf "%-30s " "$package"
	if ! [[ $status == "install ok installed" ]]; then
		apt-get install -qq -y $package &>/dev/null && printf "%s\n" "installed" || printf "%s\n" "fail"
	else
		printf "%s\n" "ok"
	fi
done < packages.txt

if ! [ -d "$homedir/.oh-my-zsh" ]; then
	echo "Downloading and installing oh-my-zsh"
	wget --quiet --no-check-certificate https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | sh
fi

if ! [ "$(exists fasd)" -eq 1 ]
then
	echo "Downloading fasd"
	git clone --quiet https://github.com/clvv/fasd.git

	echo "Setting up FASD - a command-line productivity booster"
	cd fasd
	make install --quiet
	cd ..
	rm -r fasd/
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

if [ -d "$homedir/.i3/i3-exit" ]; then
	echo "Updating i3-exit"
	cd "$homedir/.i3/i3-exit"
	git pull --quiet
	cd $scriptdir
else
	echo "Installing i3-exit"
	git clone https://gist.github.com/5675359.git "$homedir/.i3/i3-exit"
fi

if ! [ "$(exists anki)" -eq 1 ]; then
	printf "Downloading and Installing Anki "
	baseurl="http://ankisrs.net/download/mirror/"
	anki=`curl -s $baseurl | grep anki- | tail -n 1 | sed 's/.*=\"\(.*\)*....\".*/\1/'`
	printf "%-18s" "(${anki})"
	url="${baseurl}${anki}.deb"
	curl -s $url > "${anki}.deb"
	dpkg -i "${anki}.deb" &> /dev/null && printf "%s\n" "installed" || printf "%s\n" "fail"
	rm "${anki}.deb"
fi


shopt -u extglob # turn if off - whitespace removal