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

  if (is.na(doi) || doi == "NA" || nchar(doi) == 0) {
    return(NA_integer_)
  }

  message("OpenCitations: ", doi)

  max_tries <- 5
  for (i in seq_len(max_tries)) {
    # Add jitter (random pause)
    delay <- runif(1, min = 1, max = 2^i)
    Sys.sleep(delay)

    response <- tryCatch({
      httr::GET(
        url = paste0(url_base, doi),
        add_headers(Authorization = "efaa452b-43c9-42a1-8721-76ec51863458"),
        httr::timeout(5)  # <- timeout after 5 seconds
      )
    }, error = function(e) {
      warning(paste("Attempt", i, "- Connection error for", doi, ":", e$message))
      return(NULL)
    })

    # If response is successful, parse and return
    if (!is.null(response) && !httr::http_error(response)) {
      content <- httr::content(response)
      if (length(content)) {
        return(as.integer(content[[1]]))
      } else {
        return(NA_integer_)
      }
    }

    warning(paste("Attempt", i, "- Failed for", doi, "-", if (!is.null(response)) httr::status_code(response)))
  }

  warning(paste("All attempts failed for DOI:", doi))
  return(NA_integer_)
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
  mutate(search_id = if_else(DOI == "" | DOI == "NA", "", DOI)) %>%
  mutate(
    open_citations = vapply(DOI, getOpenCitations, FUN.VALUE = integer(1)),
    semantic_scholar = vapply(search_id, getSematicScholar, FUN.VALUE = integer(1)),
    google_scholar = vapply(TITLE, getGoogleScholar, FUN.VALUE = integer(1))
  ) %>%
  select(BIBTEXKEY, open_citations, semantic_scholar, google_scholar)

saveRDS(citation_counts, file = "citation_counts.rds")

