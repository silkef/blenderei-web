# blenderei-web

This is outdated. Please see the fork https://github.com/silkef/blenderei-web that is actively maintained.


Sources of my wife’s site [blenderei.de](http://www.blenderei.de). 

[index.html](index.html) is just a master file. The pages will be
generated from it by the following command:

    saxon -xsl:blenderei-html.xsl -s:index.html
    
where ```saxon``` is a suitable front-end script for an XSLT 2
processor. The generated pages will be written to the ```htdocs```
folder. If you open blenderei.xpr in oXygen, you can also use the
transformation scenario called `index` on index.html.

There may be some confusion since after there will be two files
called index.html after the transformation has run. Remember that
the master file is in this directory while the generated file is
in htdocs. Don’t edit the generated HTML files in the htdocs
directory. They will eventually be overwritten.

I’ll probably add some JS to make an additional single-page app from
index.html because on some devices, there is some flickering when
jumping between static pages. The statically generated pages will
remain there as a fallback and for indexing.

Not abundantly much to see over there yet. More content (work samples)
will be added in due time. Please note that the site’s background
image is also a sample of her work ;)
