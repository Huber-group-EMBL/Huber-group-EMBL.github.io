## ----------------------------------------------------
## postprocess the .bbl file
## ----------------------------------------------------
   
suppressPackageStartupMessages(library("magrittr"))
suppressPackageStartupMessages(library("dplyr"))
suppressPackageStartupMessages(library("lubridate"))
suppressPackageStartupMessages(library("stringr"))
suppressPackageStartupMessages(library("readr"))
 
runlatex = function(x, engine) {
  cmd = sprintf("%s %s", engine, x)
  cat("Running", cmd, "    ")
  r = system(cmd, intern = TRUE)
  if(!is.null(attr(r, "status"))) {
    print(r)
    stop("------- FAILED ----------")
  } else {
    cat(r[length(r)], "\n")
  }
}

highlightGroupMembers = function(x, group_members) {
    
    start_lines <- stringr::str_which(x, pattern = "^\\\\bibitem")
    index <- rep(seq_along(start_lines), 
                 times = diff(c(start_lines, length(x))))
    
    tmp <- split(x[start_lines[1]:(length(x)-1)], index)
    bib_entries <- lapply(tmp, FUN = function(x) { paste(x, collapse ="\n")}) %>%
        unlist()
    year <- stringr::str_match(bib_entries, pattern = "([0-9]{4})\\.")[,2] %>%
        stringr::str_c("01-07") %>%
        lubridate::ydm()
    tab <- tibble(bib_entries, year)
    
    group_members %<>%
        mutate(start_year = ifelse(is.na(start_year),
                                   "1994",
                                   start_year),
               end_year   = ifelse(is.na(end_year),
                                   as.character(year(today())),
                                   end_year)) %>%
        mutate(start_date = paste(start_year, "01-01") %>% ymd(),
               end_date   = paste0(end_year, "12-31") %>% ymd())
    
    for(i in seq_len(nrow(group_members))) {
        member <- group_members[i,]
        year_idx <- which(tab$year %within% interval(member$start_date, 
                                                     member$end_date))
        
        tab$bib_entries[year_idx] <- stringr::str_replace_all(tab$bib_entries[year_idx], 
                                                              pattern = paste0("(", member$group_member, ")"),
                                                              replacement = "\\\\whf\\{\\1\\}")
    }
    
    x[start_lines[1]:(length(x)-1)] <- strsplit(tab$bib_entries, split = "\n") %>% 
      lapply(function(x) {c(x, '')}) %>% 
      unlist()
    
    return(x)
}


procbbl = function(bblfile, group_members)
  {
    stopifnot(is.character(bblfile), length(bblfile) == 1)
      
    infile = paste(bblfile, "bbl", sep=".")
    x = readLines(infile)
    outfile = paste(bblfile, "bbl", sep=".")

    ## ----------------------------------------------------
    ## merge all continuation lines (these seem to start with two spaces)
    ##  with the preceding lines
    ## ----------------------------------------------------
    isCont = (regexpr("^  ", x) > 0) | c(FALSE, (regexpr("%$", x[-length(x)]) > 0))

    x = sub("%$", "", x)
    nx = character(sum(!isCont))
    j = 0
    for(k in seq(along=x)){
      if(isCont[k]){
        stopifnot(j!=0)
        nx[j] = paste(nx[j], x[k], sep="")
      } else {
        j=j+1
        nx[j] = x[k]
      }
    }
    stopifnot( j == length(nx), sum(!isCont) == length(nx))

    ## --------------------------------------------------
    ## highlight people bold
    ## --------------------------------------------------
    x = gsub(" +", " ", nx)

    if(length(grep("whf", x))!=0L)
      stop(paste("There are already 'whf' in", infile, "- please run 'bibtex'."))
    x = highlightGroupMembers(x, group_members = group_members)

    ## --------------------------------------------------
    ## citations
    ## FIXME (wh 2024-02-04: This piece of code here used to do more, but most of its functionality seems to have moved
    ##    moved elsewhere and now it's just a convoluted way of replacing pairs of '@' with '{' and '}'.
    ##    I now have removed the generation of these '@' in prepare_citations and now this code seems completely obsolete
    ## --------------------------------------------------
    ## fn = grep("@.+@", x)
    ## ss = strsplit(x[fn], split="")
    ## for(i in seq(along=fn)){
    ##   w = which(ss[[i]] == "@")
    ##   stopifnot(length(w)==2)
    ##   ct = paste(ss[[i]][(w[1]+1):(w[2]-1)], collapse="")
    ##   #n = gsub("(^[0-9]*)(.*)", "\\1", ct)
    ##   #source_string = ifelse(grepl("semantic", x = ct), 
    ##   #                       yes = "Source: Semantic Scholar",
    ##   #                       no = "Source: Google Scholar")
    ##   x[fn[i]] = paste(
    ##      paste0(ss[[i]][1:(w[1]-1)], collapse=""),
    ##      "{", ct, "}",
    ##      paste(ss[[i]][(w[2]+1):length(ss[[i]])], collapse=""))
    ## }
                                        # for i
    writeLines(x, con=outfile)
  } # function procbbl


ensurenoduplicates = function(x){
  
  extractcits = function(a, keyword = "citation"){
    g1 = grep(keyword, a, value=TRUE)
    g2 = sapply(strsplit(g1, split="\\{|\\}"), "[", 2)
    unique(unlist(strsplit(g2, split=",")))
  }
  
  lf = lapply(x, function(name) {
    v = readLines(paste(name, "aux", sep="."))
    if (length(v)==0) {
      message("Empty file", name)
      character(0)
    } else { 
      extractcits(v, "citation")
    }
  })
  
  uf = unlist(lf)
  if(any(duplicated(uf))) {
    cat("There are duplicated elements in the different *.bbl files:\n")
    cat(uf[duplicated(uf)], "\n\n")
    browser()
  }
    
}

