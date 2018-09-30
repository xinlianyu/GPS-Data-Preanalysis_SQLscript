install.packages("RSQLite")
install.packages("RODBC")
install.packages("reshape2")
install.packages("dplyr")
install.packages("modeest")


setwd("C:/Users/Win10S/Documents/ArcGIS")

library(RODBC)
library(RSQLite)
library(dplyr)
library(modeest)
library(reshape2)


taxidb <- odbcDriverConnect('driver={SQL Server};server=DESKTOP-86CI52L;database=taxi;trusted_connection=true',rows_at_time = 1)
#sqlTables(taxtdb)
#testtable <- sqlQuery(taxtdb, 'select * from [taxi].[sde].[APR02TRIP_PICK] WHERE carid=3')
network_merge_nodes <- sqlFetch(taxidb,"NETWORK_MERGE_NODES")
network_merge_nodes <- data.frame(network_merge_nodes)
speedlimit <- sqlQuery(taxidb, 'select OBJECTID,SPDLMTS2E,SPDLMTE2S,roadtype from [taxi].[sde].[NETWORK]')


speedlimit <- speedlimit %>%
  mutate(countSPDLMTS2E=sum(is.na(speedlimit$SPDLMTS2E)),
         countSPDLMTE2S=sum(is.na(speedlimit$SPDLMTE2S)))

roadtypespeed <- speedlimit %>%
  group_by(roadtype) %>%
  summarise(count = n(),
            countSPDLMTS2ENOna= sum(is.na(SPDLMTS2E)),
            minSPDLMTS2E = min(SPDLMTS2E,na.rm=TRUE),
            aveSPDLMTS2E =mean(SPDLMTS2E,na.rm=TRUE),
            maxSPDLMTS2E=max(SPDLMTS2E,na.rm=TRUE),
            modeSPDLMTS2E = mlv(SPDLMTS2E,method='mfv',na.rm=TRUE)[['M']],
            countSPDLMTE2SNOna= sum(is.na(SPDLMTE2S)),
            minSPDLMTE2S = min(SPDLMTE2S,na.rm=TRUE),
            aveSPDLMTE2S =mean(SPDLMTE2S,na.rm=TRUE),
            maxSPDLMTE2S =max(SPDLMTE2S,na.rm=TRUE),
            modeSPDLMTE2S = mlv(SPDLMTE2S,method='mfv',na.rm=TRUE)[['M']])


speedlimitMelt <- melt(speedlimit[,c(1,2,3,4)],id=c("OBJECTID","roadtype"))
speedlimitMelt <- speedlimitMelt[order(speedlimitMelt$OBJECTID),]
roadtypespeedMelt <- speedlimitMelt %>%
  group_by(roadtype) %>%
  summarise(count = n(),
            mode = mlv(value,method='mfv',na.rm=TRUE)[['M']])




