#
# Go through all .qmd files, extract image links ('![]()'), and compare to the set of images in the 'photos' directory.
# Report the Venn diagram.
#
# Similar for all https:// links!
#

# Load required packages
library("stringr")
library("dplyr")

# Define the directory containing .qmd files, and that with the images
qmd_dir = "."

image_extensions = c("png", "jpg", "jpeg", "svg", "gif", "webp")

imgs_exist = c(
  list.files("photos", recursive = TRUE, full.names = TRUE),
  list.files("people", recursive = TRUE, full.names = TRUE) |> (function(x) x[!grepl("\\.(qmd|R)$", x)])()
)

# Define supported image extensions
image_pattern = paste0("!\\[[^\\]]*\\]\\(([^)]+\\.(?:", paste(image_extensions, collapse = "|"), "))\\)")

# List all .qmd files in the directory (recursively)
qmd_files = list.files(qmd_dir, pattern = "\\.qmd$", recursive = TRUE, full.names = TRUE)
qmd_files = qmd_files[!grepl("^_", basename(qmd_files)) ]

# Search for image references in each file
res = lapply (qmd_files, function(f) {
  lines = readLines(f, warn = FALSE)
  matches = str_match_all(lines, image_pattern)
  lapply (matches, function(m) {
    if (nrow(m) > 0) 
      tibble(file = f, image = m[, 2])
    else 
      NULL
  }) |> bind_rows()
}) |> bind_rows()
imgs_refered_to = sort(unique(with(res, file.path(dirname(file), image))))

exist = file.exists(imgs_refered_to)
if (!all(exist)) 
  cat("Image references not found as local files:", paste(imgs_refered_to[!exist], collapse = "  "), "\n\n")

surplus = setdiff(basename(imgs_exist), basename(imgs_refered_to))
if (length(surplus) > 0) 
  cat("Images in repository but not refered to:", paste(surplus, collapse = "  "), "\n\n")
