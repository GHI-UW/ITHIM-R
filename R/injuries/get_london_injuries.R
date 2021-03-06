setwd('~/overflow_dropbox/ITHIM-R/injuries')
library(matrixStats)
library(latex2exp)
library(readstata13)
library(xlsx)
library(readODS)
library(tensorA)
library(dplyr)
library(tidyr)
library(MASS); 
library(splines)
loc <- readRDS('~/overflow_dropbox/HPC/locality.RData')

#########################################################################################################################
## code name map
lacodes <- read.ods('~/Dropbox/ITHIM/InjuryModel/spatial/UKLAcodes.ods')[[1]][-1,]
lacodes10 <- read.ods('~/Dropbox/ITHIM/InjuryModel/spatial/UKLAcodes10.ods')[[1]]
#########################################################################################################################
## road distance name
raw_road <- read.xlsx('~/overflow_dropbox/injury_predictions/VehicleTypeRoadTypeRegionalLevel.xlsx',sheetIndex=1,rowIndex=6:402,colClasses=c('numeric',rep('character',2),rep('numeric',7)))
raw_la <- read.xlsx('~/overflow_dropbox/injury_predictions/VehicleType_LALevel.xlsx',sheetIndex=1,rowIndex=6:1670,colClasses=c('numeric',rep('character',2),rep('numeric',7)))
regions <- levels(raw_road[,2])
las <- unique(raw_la[,3])

#########################################################################################################################
## injury code
load('~/overflow_dropbox/ITHIM/InjuryModel/Stats19.rda')
ss19<-tbl_df(ss19)
ss19nov <- ss19[ss19$strike_mode=='No other vehicle',c(1:7)]
ss19nov<-ss19nov[complete.cases(ss19nov),]
ss19<-ss19[complete.cases(ss19),]
ss19nov$district <- loc$local_authority_.highway.[match(ss19nov$accident_index,loc$accident_index)]
ss19$district <- loc$local_authority_.highway.[match(ss19$accident_index,loc$accident_index)]
injury_codes <- unique(ss19$district)
#########################################################################################################################
## combine
lacodes <- lacodes[lacodes$A%in%injury_codes,]
lacodes <- lacodes[lacodes$C%in%las,]
lacodes10 <- lacodes10[lacodes10$B%in%injury_codes,]
lacodes10 <- lacodes10[lacodes10$A%in%las,]
#########################################################################################################################
code_to_la <- c(lapply(lacodes10$B,function(x)lacodes10$A[which(lacodes10$B==x)]),lapply(lacodes$A,function(x)lacodes$C[which(lacodes$A==x)]))
names(code_to_la) <- c(lacodes10$B,lacodes$A)
la_to_code <- c(lapply(lacodes10$A,function(x)lacodes10$B[which(lacodes10$A==x)]),lapply(lacodes$C,function(x)lacodes$A[which(lacodes$C==x)]))
names(la_to_code) <- c(lacodes10$A,lacodes$C)
la_map <- lapply(names(la_to_code),function(x)raw_la[which(raw_la[,3]==x)[1],2])
names(la_map) <- names(la_to_code)
la_incomplete <- sapply(names(la_to_code),function(x)sum(raw_la[,3]==x))
missing_places <- names(la_to_code)[la_incomplete<11]

la_to_code <- la_to_code[la_incomplete==11]
code_to_la <- code_to_la[la_incomplete==11]
raw_la <- raw_la[!raw_la[,3]%in%missing_places,]
region_list <- lapply(regions,function(x)unique(raw_la[which(raw_la[,2]==x),3]))
names(region_list) <- regions

#########################################################################################################################
## road length name
url <- 'https://www.gov.uk/government/uploads/system/uploads/attachment_data/file/610536/rdl0202.ods'
temp <- tempfile()
download.file(url,temp)
la_road_length_sheets <- read.ods(temp)
keep_sheets <- c(3,5,7,9,11,13,15,17,19,21,22)
la_road_by_year <- list()
for(i in 1:11){
  la_road_by_year[[i]] <- la_road_length_sheets[[keep_sheets[12-i]]][7:159,c(1,2,3,7,13,ifelse(i%in%c(9,10),19,21))]
  names(la_road_by_year[[i]]) <- c('code','region','LA','Motorway','A','B')
  la_road_by_year[[i]] <- la_road_by_year[[i]][-1,]
  la_road_by_year[[i]]$code[which(la_road_by_year[[i]]=='E08000037')] <- 'E08000020'
  la_road_by_year[[i]]$code[which(la_road_by_year[[i]]=='E06000057')] <- 'E06000048'
  for(j in 4:6) la_road_by_year[[i]][[j]] <- as.numeric(gsub(',','',la_road_by_year[[i]][[j]]))
  print(la_road_by_year[[i]]$LA[!la_road_by_year[[i]]$code %in% names(code_to_la)])
  la_road_by_year[[i]] <- la_road_by_year[[i]][la_road_by_year[[i]]$code %in% names(code_to_la),]
}
#########################################################################################################################
## population numbers
pop_la <- read.ods('~/Dropbox/ITHIM/InjuryModel/spatial/populationUK.ods')[[2]][-c(1:15),]
pop_la <- pop_la[,-5]
names(pop_la) <- c('code','region','ua','la','number','area','density')
pop_la$number<-as.numeric(gsub(',','',pop_la$number))
la_pop_map <- lapply(names(code_to_la),function(x)pop_la$number[which(pop_la$code==x)])
names(la_pop_map) <- names(code_to_la)

#########################################################################################################################
ss19 <- ss19 %>% droplevels() %>%
  filter(!strike_mode%in%c('other or unknown')) %>%
  filter(cas_mode!='other or unknown') %>%
  filter(district%in%names(code_to_la))
ss19$region <- unlist(sapply(ss19$district,function(x)la_map[[code_to_la[[as.character(x)]]]]))
#ss19$population <- unlist(sapply(ss19$district,function(x)la_pop_map[[as.character(x)]]))
ss19 <- ss19[ss19$region=='London',]



######################################################################################
#saveRDS(list(ssg_reg_road=ssg_reg_road,ssg_la_road=ssg_la_road,ssg_reg_road_nov=ssg_reg_road_nov,ssg_la_road_nov=ssg_la_road_nov),'london_casualty_data.Rdata') 

