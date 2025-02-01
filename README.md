This is the source code behind <https://www.huber.embl.de/group/>, a static directory of HTML files (and resources they require).

The following is a set of instructions for group members on how to build their own instance locally, update content, and upload to the server.


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

Check <minio-README.md>

## Update the codebase in git

Use `git add`, `git commit`, and finally `git push`.
