#!/bin/bash
#
# Rscript fixcolors.R
#
find _site -type d -exec chmod 775 {} \;
find _site -type f -exec chmod 664 {} \;
rsync -avz _site/ datatransfer.embl.de:/g/huber/www-huber/group

# old:
# ssh datatransfer.embl.de 'bash -s' < ./chmod-on-server.sh
