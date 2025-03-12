options(error=recover)

## this is normally run from make.sh in the directory above
## so we include the path here
source("rscripts/procbbl.R")

## `bblfiles` is a named list. Names correspond to .tex files that are to be
## processed. Elements are vectors of .bbl files. There can be a 1:many relation between
## .tex and .bbl files since in some cases (and in particular for research report
## dossiers) I use the multibib package.

todo = read.csv(textConnection("
dir,latexname,bblname,latexengine
.,index,index,pdflatex
$HOME/huber.wolfgang/CR/2020-ISCB-fellow,cv,bibcorr|bibcollab|bibpreprint|bibold,xelatex
$HOME/huber/docs/ResearchReports/SAC2020,dossier-2020,bibcorr|bibbook|bibcollab|bibpreprint|bibold,xelatex"),
  stringsAsFactor = FALSE, header = TRUE) 

todo$dir = sub("$HOME", Sys.getenv("HOME"), todo$dir, fixed = TRUE)

group_members = readr::read_csv("group_members.csv", col_types = "ccc", skip = 8)

# -- don't do all of the tasks --
todo %<>% dplyr::filter(latexname %in% c("index"))

bblnames = strsplit(todo$bblname, "|", fixed = TRUE)

for (i in seq_len(nrow(todo))) {
  bbl = bblnames[[i]]
  oldwd = setwd(todo$dir[i])
  runlatex(todo$latexname[i], todo$latexengine[i])
  for (j in seq(along = bbl)) {
    system(sprintf("bibtex %s", bbl[j]))
    message("Highlighting group members")
    procbbl(bblfile = bbl[j],
            group_members = group_members)
  }
  message("Removing duplicates")
  ensurenoduplicates(bbl)
  for (z in 1:2) {
    message("Running ", todo$latexname[i], "(step ", z, ")")
    runlatex(todo$latexname[i], todo$latexengine[i])
  }
  setwd(oldwd)
}
