# blenderei-web

Sources of my wife’s site [blenderei.de](http://www.blenderei.de). 

[index.html](index.html) is just a master file. The pages will be generated from it by the following command:

    saxon -xsl:blender-html.xsl -s:index.html
    
where ```saxon``` is a suitable front-end script for an XSLT 2 processor. The generated pages will be written to the ```htdocs``` folder.

Not abundantly much to see over there yet. More content (work samples) will be added in due time. Please note that the site’s background image is also a sample of her work ;)
