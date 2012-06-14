#!/bin/bash

scriptdir="`pwd`"

rm /usr/local/bin/img2pdf
ln -s $scriptdir/img2pdf.py /usr/local/bin/img2pdf
chmod u+x img2pdf.py
