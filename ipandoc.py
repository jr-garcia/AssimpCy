"""
# iPandoc

Pure Python bindings to the online Docverter Pandoc document format conversion API.
This way, you get access to the power of Pandoc from anywhere, without having to meddle 
with installing anything. Useful for lightweight applications or when you want to avoid
the overhead of a full pandoc installation.

See: http://www.docverter.com/


## Platforms

Tested on Python version 2.x. 


## Dependencies

Pure Python, no dependencies. 


## Installing it

iPandoc is installed with pip from the commandline:

    pip install ipandoc


## Usage

iPandoc is very simple to use. There is only one function,
which converts a piece of text to another document format. 

This can be pretty useful, especially for dynamically converting
a project README file, which some people write in markdown format
for displaying at GitHub, over to ReStructured text for displaying
at PyPi (e.g. in your project's setup.py file). 

    import ipandoc
    markdown = open("README.md").read()
    rst = ipandoc.convert(text=markdowntext,
                          fromformat="markdown",
                          toformat="rst")

Of course, there are many other text formats you can convert between. See
API documentation link for more details on usage and options. 


## More Information:

- [Home Page](http://github.com/karimbahgat/iPandoc)
- [API Documentation](http://pythonhosted.org/iPandoc)


## License:

This code is free to share, use, reuse,
and modify according to the MIT license:

The MIT License (MIT)

Copyright (c) 2015 Karim Bahgat

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.


## Credits:

Karim Bahgat (2015)

"""

__version__ = "0.1.1"

import os
import sys
import mimetypes

VERSION = sys.version_info.major

if VERSION == 2:
    import httplib
else:
    import http.client as httplib

#######################
# multipart form post method from: https://gist.github.com/wcaleb/b6a8c97ccb0f11bd16ab
# see docverter example using this method: http://omz-forums.appspot.com/editorial/post/4955159939514368
#######################


def _post_multipart(host, selector, fields, files):
    """
    Post fields and files to an http host as multipart/form-data.
    fields is a sequence of (name, value) elements for regular form fields.
    files is a sequence of (name, filename, value) elements for data to be uploaded as files
    Return the server's response page.
    """
    content_type, body = _encode_multipart_formdata(fields, files)
    h = httplib.HTTPConnection(host)
    if VERSION == 3:
        body = body.encode()
    h.putrequest('POST', selector)
    h.putheader('content-type', content_type)
    h.putheader('content-length', str(len(body)))
    h.endheaders()
    h.send(body)
    response = h.getresponse()
    output = response.read()
    return output  # return h.file.read()


def _encode_multipart_formdata(fields, files):
    """
    fields is a sequence of (name, value) elements for regular form fields.
    files is a sequence of (name, filename, value) elements for data to be uploaded as files
    Return (content_type, body) ready for httplib.HTTP instance
    """
    BOUNDARY = '----------ThIs_Is_tHe_bouNdaRY_$'
    CRLF = '\r\n'
    L = []
    for (key, value) in fields:
        L.append('--' + BOUNDARY)
        L.append('Content-Disposition: form-data; name="%s"' % key)
        L.append('')
        L.append(value)
    for (key, filename, value) in files:
        L.append('--' + BOUNDARY)
        L.append('Content-Disposition: form-data; name="%s"; filename="%s"' % (key, filename))
        L.append('Content-Type: %s' % _get_content_type(filename))
        L.append('')
        L.append(value)
    L.append('--' + BOUNDARY + '--')
    L.append('')
    body = CRLF.join(L)
    content_type = 'multipart/form-data; boundary=%s' % BOUNDARY
    return content_type, body


def _get_content_type(filename):
    return mimetypes.guess_type(filename)[0] or 'application/octet-stream'


#########################
# end of borrowed multipart code
#########################

def convert(text, fromformat, toformat, **options):
    """
    Converts input text by sending it the Docverter online service.

    Arguments:

    - **text**: The text to be converted to another language format. If converting file use open(filepath).read().
    Text should be encoded as raw byte string (e.g. "yourtext".encode(...)".
    - **fromformat**: From language format. FORMAT can be markdown (markdown), textile (Textile),
    rst (reStructuredText), html (HTML), docbook (DocBook XML), or latex (LaTeX).
    - **toformat**: To language format. FORMAT can be markdown (markdown), rst (reStructuredText), html (XHTML 1),
    latex (LaTeX), context (ConTeXt), mediawiki (MediaWiki markup), textile (Textile), org (Emacs Org-Mode),
    texinfo (GNU Texinfo), docbook (DocBook XML), docx (Word docx), epub (EPUB book), mobi (Kindle book),
    asciidoc (AsciiDoc), or rtf (rich text format).
    - **options** (optional): Supply any additional Pandoc keyword options for the conversion process. Note: Options
    that are only meant to be set on or off should be specified as strings "true" or "false". See docverter api
    website for more details on options: http://www.docverter.com/api

    Returns:

    - The converted text.
    
    """
    # setup
    host = "c.docverter.com"
    selector = "/convert"

    # set parameters
    files = [("input_files[]", "puretext.txt", text)]
    fields = [("from", fromformat), ("to", toformat)]

    # add optional paramters
    for key, value in options.items():
        fields.append((key, value))

    # request
    results = _post_multipart(host=host, selector=selector, fields=fields, files=files)
    return results
