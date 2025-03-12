library("httr")
suppressPackageStartupMessages(library("dplyr"))
library("stringr")
library("RCurl")
library(purrr)

## Currently the version on CRAN (1.1.1) is out-of-date and will throw errors
## from deprecated functions in dplyr
pkgsAvailable <- installed.packages()[, "Package"]
if((!'bib2df' %in% pkgsAvailable) || (packageVersion('bib2df') < '1.1.2')) {
  devtools::install_github("ropensci/bib2df")
}
library("bib2df")

## read Bibtex into tibble
bib_tib = bib2df('lop.bib')

if(!is.numeric(bib_tib$YEAR)) {
  stop("One or more 'Year' entries in lop.bib contains non-numeric entries.")
}

## check PDF exists on the Huber Group site
message("Checking availabilty of PDFs")
pdf_status <- mapply(bib_tib$PDF, bib_tib$BIBTEXKEY, FUN = function(pdf, key) {
  tibble(
    PDF_found = RCurl::url.exists( paste0('https://www.huber.embl.de/pub/pdf/', pdf) ),
    BIBTEXKEY = key
  )
}, USE.NAMES = FALSE, SIMPLIFY = FALSE) %>%
  bind_rows()
filter(pdf_status, PDF_found == FALSE) %>% 
  magrittr::extract2('BIBTEXKEY') %>% 
  paste0(collapse = "\n") %>% 
  message("The files for the following entries not found:\n", .)

## check for entries in lop.bib that aren't in index.tex
index_tex <- readLines("index.tex")
missing <- lapply(bib_tib$BIBTEXKEY, FUN = function(pattern, x, fixed) { 
    !any(grepl(pattern = pattern, x = x, fixed = fixed)) 
  }, 
  x = index_tex, fixed = TRUE) %>%
  unlist()
if(any(missing)) {
  message("#####\n",
          "The following entries in lop.bib are not found in index.tex\n",
          paste0(bib_tib$BIBTEXKEY[which(missing)], collapse = "\n"))
}

## add complete EMBL URL and link to journal page into a combined NOTE field.
bib_tib2 = bib_tib |>
  left_join(pdf_status, by = "BIBTEXKEY") |>
  mutate(NOTE = if_else(PDF_found, 
                        paste0(r"(\href{https://www.huber.embl.de/pub/pdf/)", PDF, r"(}{PDF})"), "")) |>

  ## DOI
  ## latex doesn't like '_' in the DOI text, so we escape them
  mutate(DOI_SANITISED = str_replace_all(DOI, "_", "\\\\_"),
         NOTE = paste0(NOTE, if_else(DOI == "NA" | is.na(DOI), "", sprintf(" | \\href{https://doi.org/%s}{DOI:%s}", DOI, DOI_SANITISED)))) |>
  ## PREPRINT
  mutate(PREPRINT_SANITISED = str_replace_all(PREPRINT, "_", "\\\\_"),
         NOTE = paste0(NOTE, if_else(PREPRINT == "NA" | is.na(PREPRINT), "", sprintf(" | \\href{https://doi.org/%s}{Preprint}", PREPRINT)))) |>
  ## EPMC 
  mutate(NOTE = paste0(NOTE, if_else(EPMC == "NA" | is.na(EPMC), "", sprintf(" | \\href{%s}{EuropePMC}", EPMC))),
         NOTE = str_remove(NOTE, "^ \\| "))

## load our pre-calculated table of citation counts
## Use record from Semantic Scholar if that exists, otherwise try Google Scholar
citation_counts = readRDS(file = "citation_counts.rds") %>%
  mutate(count  = ifelse(is.na(semantic_scholar),  google_scholar,  semantic_scholar),
         source = ifelse(is.na(semantic_scholar), "GoogleScholar", "SemanticScholar"))

## merge citation numbers into bibtex table and append to the NOTE field
bib_tib3 = bib_tib2 |>
  left_join(citation_counts, by = "BIBTEXKEY") %>%
  mutate(NOTE = if_else(is.na(count) | as.integer(count) < 10,
                        NOTE, paste0(" (", count, " citations", source, ")", NOTE))) |>
  select(-count, -PDF_found) 

## write updated Bibtex file
df2bib(bib_tib3, file = "lopcit.bib")

