
people = read.csv(textConnection("
Constantin Ahlmann-Eltze,PhD candidate
Hosna Baniadam,PhD candidate
Simone Bell,Senior Project Manager
Klemens Tuemay Capraz,PhD candidate
Erin Chung,PhD candidate
Donnacha Fitzgerald,PhD candidate
Anastasiia Horlova,PhD candidate
Sarah Kaspar,Consultant Statistics / Data Science
Matthias Meyer-Bender,PhD candidate
Thomas Naake,Postdoctoral researcher
Stefan Peidli,Postdoctoral researcher
Julia Philipp,Data Manager / Data Scientist
Petr Smirnov,Postdoctoral researcher"), header = FALSE) 

colnames(people) = c("name", "fun")
  
for(i in seq_len(nrow(people)))
  Biobase::copySubstitute(
    src = "person-template.qmd", 
    dest = paste0(gsub(" ", "-", tolower(people$name[i])), ".qmd"),
    symbolValues = list(NAME = people$name[i], 
                        FUNCTION = people$fun[i])
  )
