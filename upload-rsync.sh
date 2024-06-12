#!/bin/bash
Rscript fixcolors.R
rsync -vrclpt _site/ datatransfer.embl.de:/g/huber/www-huber/group
ssh datatransfer.embl.de 'bash -s' < ./chmod-on-server.sh
