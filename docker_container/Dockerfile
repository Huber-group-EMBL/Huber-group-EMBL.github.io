FROM rocker/rstudio:latest

# Install Quarto
RUN wget https://quarto.org/download/latest/quarto-linux-amd64.deb && \
    dpkg -i quarto-linux-amd64.deb && \
    rm quarto-linux-amd64.deb

## Install LaTeX packages, tth and system libraries for ggplot2, ggraph, ggforce, kableExtra etc.
#RUN R -e "install.packages(c('kableExtra', 'scholar', 'bib2df', 'RCurl', 'europepmc', 'RCurl', 'bib2df', 'httr', 'lubridate', 'scholar'), repos='https://cloud.r-project.org')"
RUN apt-get update && apt-get install -y \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    libfontconfig1-dev \
    libfreetype6-dev \
    libharfbuzz-dev \
    libfribidi-dev \
    libpng-dev \
    libtiff5-dev \
    libjpeg-dev \
    texlive-fonts-recommended \
    texlive-fonts-extra \
    tth \
    && rm -rf /var/lib/apt/lists/*

# Install R packages
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
