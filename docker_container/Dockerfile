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
    libxml2-dev \
    libssl-dev \
    libcurl4-openssl-dev \
    libfontconfig1-dev \
    libfreetype6-dev \
    libpng-dev \
    libharfbuzz-dev \
    libfribidi-dev \
    && rm -rf /var/lib/apt/lists/*

# Install R packages (duplicates removed)
RUN R -e "install.packages(c('httr', 'kableExtra', 'scholar', 'bib2df', 'RCurl', 'europepmc', 'lubridate' \
), repos='https://cloud.r-project.org')"

# Set default workdir
WORKDIR /project

# Default command (can be overridden)
CMD ["bash"]
