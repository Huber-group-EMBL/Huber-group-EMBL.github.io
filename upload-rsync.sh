#!/bin/bash
#
# *** This is no longer relevant, since the web server serves from an S3 bucket.
# *** Please see  minio-README.md
#
# find _site -type d -exec chmod 775 {} \;
# find _site -type f -exec chmod 664 {} \;
# rsync -avz _site/ datatransfer.embl.de:/g/huber/www-huber/group


mc mirror --overwrite _site wwwhuber/www-huber/group
