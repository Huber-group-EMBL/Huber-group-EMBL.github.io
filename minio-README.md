### Install MinIO Client

If you haven’t already, install the MinIO Client `mc`. On MacOS:

```
brew install minio-mc.
```

Or see <https://min.io>, <https://dl.min.io>.

### Create access key

If you haven’t already, login to <https://console.s3.embl.de/> to create an access key to the bucket you want to access (or ask an owner to do it for you).

### Configure MinIO Client

Add the EMBL S3-compatible server https://s3.embl.de

```
mc alias set wwwhuber https://s3.embl.de YOUR-ACCESS-KEY YOUR-SECRET-KEY
```

- here, `wwwhuber` is the alias name that will below be used for the S3 service; replace this with your preferred alias name.
- if you do not aim for https://s3.embl.de, replace this with the endpoint URL of your S3-compatible service.
- Replace `ACCESS_KEY` and `SECRET_KEY` with your AWS or MinIO credentials.
	
### Use `mc mirror` for synchronization

The `mc mirror` command is used to synchronize files and directories between your local filesystem and the S3 bucket. To sync from your local directory to the S3 bucket:

```
mc mirror /path/to/local/directory <youralias>/<bucket-name>
```

Key Options:

-	`--overwrite`: Ensures that files in the destination are replaced with updated versions from the source.
-	`--remove`: Deletes files in the destination that are no longer in the source directory (to maintain exact sync).
-	`--watch`: Continuously monitors the source directory for changes and mirrors them to the destination.
-	`--dry-run`: Simulates the operation without making actual changes, so you can review what will happen.

### Verify the Sync

You can list the contents of the S3 bucket to verify that the files were copied, interactively via <https://console.s3.embl.de/browser> or on the command line via

```
mc ls myalias/mybucket/backup
```

### Group website specific instantiation of the above

```
cd /Users/whuber/clones/Huber-group-EMBL.github.io
mc mirror --overwrite _site wwwhuber/www-huber/group
```

The following only if the redirection file has been deleted/corrupted:

```
mc cp resources/redirect.html wwwhuber/www-huber/index.html
```
