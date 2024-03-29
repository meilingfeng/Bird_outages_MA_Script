library(tidyverse)
library(factoextra)

load("Objects and Data/4_dp_towns_updated.rda")
load("Objects and Data/0_species_list.rda")
  

#Principle component analysis (bird activity dimension reduction)
#----------------------------------------------------------------------------------------
pr.all<-dp_towns3[complete.cases(dp_towns3), ]  

#run PCA on just bird DPs, scaling bases the PCs on correlation
pr.out.all=prcomp(pr.all[,toupper(name_list$sp_file[-16])], scale=TRUE)


#PC loading vectors
vectors<-as.data.frame(pr.out.all$rotation)
write.csv(vectors,"Outputs/BirdDP_pcloadings_updated.csv")


#Percent contribution of variance of PCAs
perc.all <- (pr.out.all$sdev^2/sum(pr.out.all$sdev^2))

df.all <- data.frame(pc = c('1','2','3','4','5-15'), 
                      perc = c(perc.all[1:4],
                               sum(perc.all[-c(1:4)])))%>% 
  mutate(pc = factor(pc, levels = rev(c('1','2','3','4','5-15'))))

#Visual of Cumulative Variance across PCs
ggplot(df.all)+
  geom_bar(aes(y = perc, x=NA, fill = pc),
           stat = "identity")+
  labs(y="Proportion of Variance",
       x="",
       fill="PC") +
  scale_fill_viridis_d(option = "plasma")+
  theme_bw()+
  theme(axis.text.x = element_blank())



#Extract PC variables
pr.ind <- get_pca_ind(pr.out.all)
coord<-merge(pr.all[,c("city","Year","season","week","date")],pr.ind$coord,by=0,all.x=TRUE)%>% # Coordinates
  dplyr::select(-c("Row.names"))
write.csv(coord, "Outputs/BirdDP_pcvalues_updated.csv",row.names = FALSE)


save(pr.out.all, coord,vectors,file="Objects and Data/5_DP_PCA_updated.rda")



