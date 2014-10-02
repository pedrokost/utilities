#!/usr/bin/env python

import Image
import sys
import zlib
import argparse
import struct
from datetime import datetime

def parse(cont, indent=1):
    if type(cont) is dict:
        return "<<\n"+"\n".join([4*indent*" "+"%s %s"%(k, parse(v, indent+1)) for k, v in cont.items()])+"\n"+4*(indent-1)*" "+">>"
    elif type(cont) is int or type(cont) is float:
        return str(cont)
    elif isinstance(cont, obj):
        return "%d 0 R"%cont.get_identifier()
    elif type(cont) is str:
        return cont
    elif type(cont) is list:
        return "[ "+" ".join([parse(c, indent) for c in cont])+" ]"

class obj():
    def __init__(self, content, stream=None):
        self.content = content
        self.stream = stream

    def tostring(self, identifier):
        self.identifier = identifier
        if self.stream:
            return "%d 0 obj "%identifier+parse(self.content)+"\nstream\n"+self.stream+"\nendstream\nendobj\n"
        else:
            return "%d 0 obj "%identifier+parse(self.content)+" endobj\n"

    def get_identifier(self):
        if not hasattr(self, 'identifier'):
            raise Exception("no id set yet, call tostring() on obj first")
        return self.identifier

def main(images, dpi, title=None, author=None, creator=None, producer=None,
    creationdate=None, moddate=None, subject=None, keywords=None):

    version = 3 # default pdf version 1.3

    now = datetime.now()

    info = dict()
    if title:
        info["/Title"] = "("+title+")"
    if author:
        info["/Author"] = "("+author+")"
    if creator:
        info["/Creator"] = "("+creator+")"
    if producer:
        info["/Producer"] = "("+producer+")"
    if creationdate:
        info["/CreationDate"] = "(D:"+creationdate.strftime("%Y%m%d%H%M%S")+")"
    else:
        info["/CreationDate"] = "(D:"+now.strftime("%Y%m%d%H%M%S")+")"
    if moddate:
        info["/ModDate"] = "(D:"+moddate.strftime("%Y%m%d%H%M%S")+")"
    else:
        info["/ModDate"] = "(D:"+now.strftime("%Y%m%d%H%M%S")+")"
    if subject:
        info["/Subject"] = "("+subject+")"
    if keywords:
        info["/Keywords"] = "("+",".join(keywords)+")"

    info = obj(info)

    pagestuples = list()

    for im in images:
        try:
            imgdata = Image.open(im)
        except IOError:
            # test if it is a jpeg2000 image
            im.seek(0)
            if im.read(12) != "\x00\x00\x00\x0C\x6A\x50\x20\x20\x0D\x0A\x87\x0A":
                print "cannot read input image"
                exit(1)
            # image is jpeg2000
            imgformat = "JP2"
            im.seek(48)
            height, width = struct.unpack(">II", im.read(8))
            color = "RGB" # TODO: read real colorspace
            if dpi:
                dpi_x, dpi_y = dpi, dpi
            else:
                dpi_x, dpi_y = (96, 96) # TODO: read real dpi
        else:
            width, height = imgdata.size
            if dpi:
                dpi_x, dpi_y = dpi, dpi
            else:
                dpi_x, dpi_y = imgdata.info.get("dpi", (96, 96))
            imgformat = imgdata.format
            color = imgdata.mode

        if color == 'L':
            color = "/DeviceGray"
        elif color == 'RGB':
            color = "/DeviceRGB"
        else:
            print "unsupported color space:", color
            exit(1)

        pdf_x, pdf_y = 72.0*width/dpi_x, 72.0*height/dpi_y # pdf units = 1/72 inch

        # either embed the whole jpeg or deflate the bitmap representation
        if imgformat is "JPEG":
            ofilter = [ "/DCTDecode" ]
            im.seek(0)
            imgdata = im.read()
        elif imgformat is "JP2":
            ofilter = [ "/JPXDecode" ]
            im.seek(0)
            imgdata = im.read()
            version = 5 # jpeg2000 needs pdf 1.5
        else:
            ofilter = [ "/FlateDecode" ]
            imgdata = zlib.compress(imgdata.tostring())
        im.close()

        image = obj({
            "/Type": "/XObject",
            "/Subtype": "/Image",
            "/Filter": ofilter,
            "/Width": width,
            "/Height": height,
            "/ColorSpace": color,
            "/BitsPerComponent": 8, # hardcoded as PIL doesnt provide bits for non-jpeg formats
            "/Length": len(imgdata)
        }, imgdata)

        text = "q\n%f 0 0 %f 0 0 cm\n/Im0 Do\nQ"%(pdf_x, pdf_y)

        content = obj({
            "/Length": len(text)
        }, text)

        page = obj({
            "/Type": "/Page",
            "/Resources": {
                "/XObject": {
                    "/Im0": image
                }
            },
            "/MediaBox": [0, 0, pdf_x, pdf_y],
            "/Contents": content
        })

        pagestuples.append((image, content, page))

    pages = obj({
        "/Type": "/Pages",
        "/Kids": [ pagetuple[2] for pagetuple in pagestuples ],
        "/Count": len(pagestuples)
    })

    catalog = obj({
        "/Pages": pages,
        "/Type": "/Catalog"
    })

    objects = list()
    objects.append(info.tostring(3*(len(pagestuples)+1)))
    for i, (image, content, page) in enumerate(reversed(pagestuples)):
        objects.append(image.tostring(3*(len(pagestuples)-i+1)-1))
        objects.append(content.tostring(3*(len(pagestuples)-i+1)-2))
        objects.append(page.tostring(3*(len(pagestuples)-i+1)-3))
    objects.append(pages.tostring(2))
    objects.append(catalog.tostring(1))
    objects.reverse()

    xreftable = list()

    result  = "%%PDF-1.%d\n"%version

    xreftable.append("0000000000 65535 f \n")
    for o in objects:
        xreftable.append("%010d 00000 n \n"%len(result))
        result += o

    xrefoffset = len(result)
    result += "xref\n"
    result += "0 %d\n"%len(xreftable)
    for x in xreftable:
        result += x
    result += "trailer\n"
    result += parse({"/Size": len(xreftable), "/Info": info, "/Root": catalog})+"\n"
    result += "startxref\n"
    result += "%d\n"%xrefoffset
    result += "%%EOF\n"

    return result

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='lossless conversion/embedding of images (in)to pdf')
    parser.add_argument('images', metavar='infile', type=argparse.FileType('r'),
                        nargs='+', help='input file(s)')
    parser.add_argument('-o', '--output', metavar='out', type=argparse.FileType('w'),
                        default=sys.stdout, help='output file (default: stdout)')
    def positive_float(string):
        value = float(string)
        if value <= 0:
            msg = "%r is not positive"%string
            raise argparse.ArgumentTypeError(msg)
        return value
    parser.add_argument('-d', '--dpi', metavar='dpi', type=positive_float, help='dpi for pdf output (default: 96.0)')
    parser.add_argument('-t', '--title', metavar='title', type=str, help='title for metadata')
    parser.add_argument('-a', '--author', metavar='author', type=str, help='author for metadata')
    parser.add_argument('-c', '--creator', metavar='creator', type=str, help='creator for metadata')
    parser.add_argument('-p', '--producer', metavar='producer', type=str, help='producer for metadata')
    def valid_date(string):
        return datetime.strptime(string, "%Y-%m-%dT%H:%M:%S")
    parser.add_argument('-r', '--creationdate', metavar='creationdate',
        type=valid_date, help='creation date for metadata in YYYY-MM-DDTHH:MM:SS format')
    parser.add_argument('-m', '--moddate', metavar='moddate',
        type=valid_date, help='modification date for metadata in YYYY-MM-DDTHH:MM:SS format')
    parser.add_argument('-s', '--subject', metavar='subject', type=str, help='subject for metadata')
    parser.add_argument('-k', '--keywords', metavar='kw', type=str, nargs='+', help='keywords for metadata')
    args = parser.parse_args()
    args.output.write(main(args.images, args.dpi, args.title, args.author,
        args.creator, args.producer, args.creationdate, args.moddate,
        args.subject, args.keywords))
