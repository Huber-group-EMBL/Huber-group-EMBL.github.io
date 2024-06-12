fn = "_site/site_libs/bootstrap/bootstrap.min.css"
readLines(fn) |> stringr::str_replace_all("#eb6864", "#4169e1") |> writeLines(con = fn)
message(paste("Fixed colors in", fn))