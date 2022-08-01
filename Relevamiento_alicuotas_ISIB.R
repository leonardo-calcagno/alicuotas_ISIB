
library(tidyverse)
library(readxl)
library(openxlsx)
library(readr)
library(xml2)
library(RCurl)
library(rlist)
library(httr)
library(plyr)

rm(list=ls())
gc()
setwd("C:/Users/Ministerio/Documents/")
########Obtener todos los cuadros de la página de alícuotas de ERREPAR ---------

#ERREPAR tiene un código de protección: no se puede bajar nada con R. Lo que hay que hacer es: 
    #1- Abrir la página con las alícuotas en el navegador
    #2- Click derecho: "Ver código fuente de la página"
    #3 Se debería abrir el código fuente en una nueva pestaña. Ahí de nuevo click derecho, "guardar como"
    #4 Guardarlo en la carpeta requerida, en el formato "página web, sólo HTML. 
    #5 Lanzar readHTMLTable sobre el archivo .htm resultante

alicuotas_ERREPAR<- function(input){
  
  tables <- readHTMLTable(paste0(input,".htm"),header="borrar")
  tables <- list.clean(tables, fun = is.null, recursive = FALSE) # Esta instrucción es para quedarse sólo con las tablas 
  #n.rows <- unlist(lapply(tables, function(t) dim(t)[1]))
  #cuadro_mas_largo<-tables[[which.max(n.rows)]]
  n.tables<-length(tables)
  tables<-setNames(tables,c(1:n.tables)) #Cuadros renombrados según orden de aparición en la página
  
  #tables<-lapply(tables,function(x) dplyr::mutate(x,mergeid=row_number())
  #)
  output<-ldply(tables,data.frame,.id="cuadro")
}
df_buenos_aires_22<-alicuotas_ERREPAR("buenos_aires_2022")
df_catamarca_22<-alicuotas_ERREPAR("catamarca_2022")
df_CABA_22<-alicuotas_ERREPAR("CABA_2022")
df_cordoba_22<-alicuotas_ERREPAR("cordoba_2022")
df_corrientes_22<-alicuotas_ERREPAR("corrientes_2022")

df_la_pampa_22<-alicuotas_ERREPAR("la_pampa_2022")

tables <- readHTMLTable("buenos_aires_2022.htm",header="borrar")
tables <- list.clean(tables, fun = is.null, recursive = FALSE) # Esta instrucción es para quedarse sólo con las tablas 
#n.rows <- unlist(lapply(tables, function(t) dim(t)[1]))
#cuadro_mas_largo<-tables[[which.max(n.rows)]]

n.tables<-length(tables)
tables<-setNames(tables,c(1:n.tables)) #Cuadros renombrados según orden de aparición en la página

#tables<-lapply(tables,function(x) dplyr::mutate(x,mergeid=row_number())
#)


df_buenos_aires_22<-ldply(tables,data.frame,.id="cuadro")%>%
  mutate(es_alicuota=ifelse(substr(V1,start=1,stop=1)%in% c("0","1","2","3","4","5","6","7","8","9"), 1,
                            ifelse(substr(V1,start=2,stop=2) %in% c("0","1","2","3","4","5","6","7","8","9"), 1, 
                                   ifelse(substr(V1,start=2,stop=2) %in% c("0","1","2","3","4","5","6","7","8","9"), 1, 0)
                                   )
                            )
         )%>%
  subset(es_alicuota==1)%>%
  select(-c(es_alicuota,borrar))

apariciones_CLAE<-df_buenos_aires_22%>%
  group_by(V1)%>%
  tally()%>%
  arrange(desc(n))
head(apariciones_CLAE)
head(df_buenos_aires_22)

