find htdocs -type d -exec chmod 775 {} \;
find htdocs -type f -exec chmod 664 {} \;
rsync -avz -e ssh htdocs/ wfi:www/blenderei/
