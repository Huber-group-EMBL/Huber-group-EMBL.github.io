x = readLines("index.html")

## stop using "quirks mode" html
x = gsub(pattern = '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN"', 
         replacement = '<!DOCTYPE html>', x = x)
x = gsub(pattern = '           "http://www.w3.org/TR/REC-html40/loose.dtd">', replacement = '', x = x)

i = grep("^ <dt><a href", x)
x[i] = sub("<a href.+?>", "", sub("</a>", "", x[i]))
x  = sub(">url", " target=\"Wolfgang Huber Publications\">url", x)

## insert file and link icons
x = gsub('>Journal Site</a>\\.?', '><img src="icons/link.gif"></a>', x)
#x = gsub('>PDF</a>[,\\.]', '><img src="icons/file.gif"></a>', x)


## put links on a separate line
x = gsub("^[[:blank:]]*<a href=", "<br><a href=", x = x)
x = gsub("^[[:blank:]]*-[[:blank:]]*<a href=", "<br><a href=", x = x)
x = gsub(")<a href=", ")<br><a href=", x = x)
x = gsub('</a>$.', '</a>', x)

## format citations
x = gsub(pattern = "(\\(<?b?>?[0-9]* citations) ([a-zA-Z]*)(<?/?b?>?\\))", 
         replacement = "<span class='citation'>\\1<span class='citation-source'>\\2</span>\\3</span>", 
         x = x)
x = gsub(pattern = "SemanticScholar", 
         replacement = ", source: Semantic Scholar", 
         x = x)
x = gsub(pattern = "GoogleScholar", 
         replacement = ", source: Google Scholar", 
         x = x)

## make links open in new page
x = gsub('<a href=', '<a target="_blank" href=', x, fixed = TRUE)

## clean up formatting
divp = which(x=='<div class="p"><!----></div>')
br = divp[x[divp+1L]=='</dd>']
x[br] = "<br/><br/>"
x = x[-(br-1L)]
divp = which(x=='<div class="p"><!----></div>')
x = x[-c(divp, divp-1L)]

## remove footnotes title 
x[which(x=="<hr /><h3>Footnotes:</h3>")] = "<br />"

i1 = grep("^<meta name=\"GENERATOR\"", x)
i2 = grep("^<h2>Publications Huber group</h2>", x)
stopifnot(length(i1)==1, length(i2)==1, i1 < i2)
x = c(
  x[1:(i1-1)],
  '<head>',
  '<link rel="stylesheet" id="vfwp-css" href="https://www.embl.org/groups/huber/wp-content/themes/vf-wp/assets/css/styles.css?ver=1.0.0-beta.5" type="text/css" media="all">',
  '<link rel="stylesheet" href="style.css" />',
  "<script>
const reportHeight = (event) => {
    console.log('needed height', document.body.scrollHeight)
    top.postMessage('height:' + document.body.scrollHeight, 'https://www.embl.org')
}

addEventListener('DOMContentLoaded', reportHeight)
addEventListener('load', reportHeight)
addEventListener('resize', reportHeight)
</script>",
  '</head>',
  paste("Page built:", format(Sys.time(), "%d %b %Y %H:%M"), "<br><br>"),
   x[(i2+1):length(x)]
)

writeLines(x, "pub_raw.html")
