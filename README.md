# One time actions

## Install Quarto 

Please see here: <https://quarto.org/>

## Install the webr extension for Quarto

Run

```
quarto add coatless/quarto-webr
```

[See here for more on this](<https://github.com/coatless/quarto-webr).

# To make webpage updates

## Update your local codebase

```
git pull
```

## Edit

Add new files or edit existing ones. 

## Render 

To build the website, run

```
quarto render
```

in the top-level directory of this repository.
A directory of "static" HTML files will be created in the `_site` folder.

## Upload to EMBL's webserver

Run
```
./upload-rsync.sh
```

This uploads the directory to the EMBL NFS file systems. It will take a few more minutes before the changes are visible on <https://www.huber.embl.de/group/> since these files will need to be further copied to an S3 bucket that serves the EMBL webserver, which is done by a demon. (I am not quite sure about this process.)

## Update the codebase in git

Use `git add`, `git commit`, and finally `git push`.
