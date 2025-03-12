library("dplyr")
library("magrittr")
library("httr")
library("scholar")
library("bib2df")
library("stringr")


## Semantic Scholar
getSematicScholar <- function(doi) {
  
  url_base <- 'https://api.semanticscholar.org/v1/paper/'
  
  if( is.na(doi) | doi == "NA" | nchar(doi) == 0 ) {
    n_citations <- NA
  } else {
    message("Semantic Scholar: ", doi)
    n_citations  <- httr::GET( paste0(url_base, doi) ) %>%
      httr::content() %>%
      magrittr::extract2('citations') %>%
      length()
    
    ## Semantic Scholar is rate-limited to 100 queries every 5 minutes
    Sys.sleep(3)
  }
  
  return(n_citations)
  
}

getOpenCitations <- function(doi) {
  
  url_base <- 'https://w3id.org/oc/index/api/v1/citation-count/'
  
  if( is.na(doi) | doi == "NA" | nchar(doi) == 0 ) {
    n_citations <- NA
  } else {
    message("OpenCitations: ", doi)
    ##  We use an API token generated for the email address mike.smith@embl.de
    result <- httr::GET( url = paste0(url_base, doi),
                         add_headers(Authorization = "efaa452b-43c9-42a1-8721-76ec51863458")) %>%
      httr::content() 
    
    if(length(result)) {
      n_citations <- result %>%
        magrittr::extract2(1) %>% 
        as.integer()
    } else {
      n_citations <- NA
    }
  }
  
  return(n_citations)
}

## this requires a perfect match between the title in the bibtex entry
## and the result from Google Scholar.  Not ideal, but we only use it for
## references without a DOI
getGoogleScholar <- function(title) {
  ## this gets Wolfgang's Google Scholar data
  wh_gscholar <- scholar::get_publications('gI8o6x8AAAAJ')
  
  bibtex_title <- tolower(title) %>% 
    str_remove_all("\\{|\\}")
  
  res <- wh_gscholar %>% 
    mutate(t2 = tolower(title)) %>%
    filter(t2 == bibtex_title)
  
  n_citations <- ifelse(nrow(res), as.integer(res$cites), NA)
  return(n_citations)
}


cleandoi <- function(doi) {
  cdoi =
    stringr::str_remove(doi, '(https|http)?(://)?(dx.)?doi.org/') |>
    stringr::str_remove('doi:') |>
    stringr::str_remove('^"') |>
    stringr::str_remove('"$') |>
    stringr::str_remove('\\},$')
  
  stopifnot(identical(cdoi, doi))
  cdoi
}

## remove "comment" lines from bibtex.  bib2df tries to include these as 
## fields in the table later
tmp <- readLines('lop.bib')
idx_to_remove <- grep(pattern = "^%", x = tmp)
if(length(idx_to_remove)) {
  tmp <- tmp[-idx_to_remove]
}
tf <- tempfile()
writeLines(tmp, tf)

citation_counts <- bib2df(tf) %>%
  mutate(DOI = cleandoi(DOI)) %>%
  mutate(search_id = if_else(DOI == "" | DOI == "NA", CORPUS, DOI)) %>%
  mutate(
    open_citations = vapply(DOI, getOpenCitations, FUN.VALUE = integer(1)),
    semantic_scholar = vapply(search_id, getSematicScholar, FUN.VALUE = integer(1)),
    google_scholar = vapply(TITLE, getGoogleScholar, FUN.VALUE = integer(1))
  ) %>%
  select(BIBTEXKEY, open_citations, semantic_scholar, google_scholar)

saveRDS(citation_counts, file = "citation_counts.rds")

