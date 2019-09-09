# you may need to revise the issue or volume number.
# you want to revise the output path

baseurl <- "https://www.nature.com/nature/volumes/572/issues/7769"

library(rvest)
library(pdftools)

scraping_wiki <- read_html(baseurl)
scraping_wiki$node
ids <- scraping_wiki %>%
  html_nodes("article") %>%
  html_nodes("div") %>%
  html_nodes("h3") %>%
  html_nodes("a") %>%
  html_attr('href')
  #html_text()

ids <- gsub("/articles/","",ids)

types <- scraping_wiki %>%
  html_nodes("article") %>%
  html_nodes("div") %>%
  html_nodes("p") %>%
  html_nodes("span") %>%
  html_text()

types <- types[types!=" | "  ]

i=1
for(i in 1:length(types)){
  if(types[i] %in% c("Letter","Article","Author Correction","Publisher Correction") ){
    this <- paste0("https://www.nature.com/articles/",ids[i],".pdf")
  } else {
    this <- paste0("https://www.nature.com/magazine-assets/",
                   ids[i],
                   "/", ids[i],
                   ".pdf")
  }
  
  to_save <- paste0("~/Desktop/test_download/",i,".pdf")
  if(!file.exists(to_save)){
    download.file (this,destfile =to_save  )	
  }
  
  print(paste(i, length(types), "done"))
  #Sys.sleep( 5+ sample(1:10,1)    )
  
}

## merge pdf as one
#files <- list.files("~/Desktop/test_download/",full.names = T)
files <- paste0("/Users/lablap/Desktop/test_download/",1:length(types),".pdf")
dir.create("/Users/lablap/Desktop/test_download/bk/")
file.copy(from = files,to="/Users/lablap/Desktop/test_download/bk/")
library(tools)
j=1
to_rm <- vector()
for(j in 1:(length(files)-1) ){
  dups <- md5sum(files[j]) == md5sum(files[j+1])
  print(dups)
  if(dups){
    to_rm <- c(to_rm,j)
  }
}
files_clean <- files[-to_rm]

k=1
k=26
for(k in 1:length(files_clean)){
  one_check= NULL
  one_check2=NULL
  one_check3=NULL
  all_check=NULL
  one_text <- pdf_text(files_clean[k])
  one_check <- grep("Article RESEARCH\nMethods",one_text)
  one_check2 <- grep("RESEARCH Letter\nMethods",one_text)
  one_check3 <- grep("Letter RESEARCH\nMethods",one_text)
  one_check4 <- grep("RESEARCH Article\nMethods",one_text)
  
    
  
  if(length(one_check)==1 ){
    all_check <- one_check
  } else if (length(one_check2)==1 ){
    all_check <- one_check2
  } else if (length(one_check3)==1) {
    all_check <- one_check3
  } else if (length(one_check4)==1) {
    all_check <- one_check4
  }
  if(length(all_check)==1){
    print(paste("file",k, all_check))
    pdf_subset(files_clean[k],
               pages = 1:(all_check-1), 
               output = paste0(files_clean[k],"_simple.pdf"))
    files_clean[k] <- paste0(files_clean[k],"_simple.pdf")
  }
}
pdf_combine(files_clean, output = "~/Desktop/nature_full.pdf")


###### end
