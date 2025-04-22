FROM rocker/rstudio:latest

# Install Quarto
RUN wget https://quarto.org/download/latest/quarto-linux-amd64.deb && \
    dpkg -i quarto-linux-amd64.deb && \
    rm quarto-linux-amd64.deb

# Install LaTeX packages and tth
RUN apt-get update && apt-get install -y \
    texlive-fonts-recommended \
    texlive-fonts-extra \
    tth

# Install R packages
#RUN R -e "install.packages(c('kableExtra', 'scholar', 'bib2df', 'RCurl', 'europepmc', 'RCurl', 'bib2df', 'httr', 'lubridate', 'scholar'), repos='https://cloud.r-project.org')"
RUN apt-get update && apt-get install -y \
    texlive-latex-base \
    texlive-latex-extra \
    texlive-fonts-recommended \
    texlive-fonts-extra \
    texlive-bibtex-extra \
    biber \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    tth \
    && apt-get clean

RUN Rscript -e "\
  pkgs <- c('kableExtra', 'scholar', 'bib2df', 'RCurl', 'europepmc', 'httr', 'lubridate', 'readr', 'rmarkdown', 'knitr'); \
  missing <- pkgs[!sapply(pkgs, requireNamespace, quietly = TRUE)]; \
  install.packages(missing, repos = 'https://cloud.r-project.org'); \
  still_missing <- missing[!sapply(missing, requireNamespace, quietly = TRUE)]; \
  if (length(still_missing) > 0) stop('Package installation failed: ', paste(still_missing, collapse = ', '))"

# Set default workdir
WORKDIR /project

# Default command (can be overridden)
CMD ["bash"]
