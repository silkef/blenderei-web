# blenderei-web

Sources of my site [blenderei.de](http://www.blenderei.de). 

[index.html](index.html) is just a master file. The pages will be
generated from it by the following command:

    saxon -xsl:blenderei-html.xsl -s:index.[lang].html
    
where ```saxon``` is a suitable front-end script for an XSLT 2
processor and [lang] is `de` or `en`. The generated pages will be 
written to the ```htdocs/[lang]/``` folder. If you open blenderei.xpr
in oXygen, you can also use the transformation scenario called 
`index` on index.de.html or index.en.html.

Don’t edit the generated HTML files in the htdocs directory. 
They will eventually be overwritten.

We’ll probably add some JS to make an additional single-page app from
index.html because on some devices, there is some flickering when
jumping between static pages. The statically generated pages will
remain there as a fallback and for indexing.
