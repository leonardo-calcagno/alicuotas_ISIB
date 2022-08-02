
library(tidyverse)
library(readxl)
library(openxlsx)
library(readr)
library(XML)
library(xml2)
library(RCurl)
library(rlist)
library(httr)
library(plyr)
library(googlesheets4)
library(googledrive)

rm(list=ls())
gc()
setwd("C:/Users/Ministerio/Documents/alicuotas_ISIB/")
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
df_chaco_22<-alicuotas_ERREPAR("chaco_2_2022")
df_chubut_22<-alicuotas_ERREPAR("chubut_2022")
df_entre_rios_22<-alicuotas_ERREPAR("entre_rios_2_2022")
df_formosa_22<-alicuotas_ERREPAR("formosa_2022")
df_jujuy_22<-alicuotas_ERREPAR("jujuy_2022")
df_la_pampa_22<-alicuotas_ERREPAR("la_pampa_2022")
df_la_rioja_22<-alicuotas_ERREPAR("la_rioja_2022")
df_mendoza_22<-alicuotas_ERREPAR("mendoza_2022")
df_misiones_22<-alicuotas_ERREPAR("misiones_2022")
df_neuquen_22<-alicuotas_ERREPAR("neuquen_2022")
df_rio_negro_22<-alicuotas_ERREPAR("rio_negro_2022")
df_salta_22<-alicuotas_ERREPAR("salta_2022")
df_san_juan_22<-alicuotas_ERREPAR("san_juan_2022")
df_san_luis_22<-alicuotas_ERREPAR("san_luis_2022")
df_santa_cruz_22<-alicuotas_ERREPAR("santa_cruz_2022")
df_santa_fe_22<-alicuotas_ERREPAR("santa_fe_2022")
df_santiago_del_estero_22<-alicuotas_ERREPAR("santiago_del_estero_2022")
df_TDF_22<-alicuotas_ERREPAR("tdf_2022")
df_tucuman_22<-alicuotas_ERREPAR("tucuman_2022")





gs4_auth() #Connection to google account

id_carpeta<-drive_get("Relevamiento_alicuotas")
gs4_create(name="buenos_aires_22",sheets=df_buenos_aires_22)
drive_mv(file="buenos_aires_22",path=id_carpeta)

gs4_create(name="CABA_22",sheets=df_CABA_22)
drive_mv(file="CABA_22",path=id_carpeta)

gs4_create(name="catamarca_22",sheets=df_catamarca_22)
drive_mv(file="catamarca_22",path=id_carpeta)

gs4_create(name="chaco_22",sheets=df_chaco_22)
drive_mv(file="chaco_22",path=id_carpeta)

gs4_create(name="chubut_22",sheets=df_chubut_22)
drive_mv(file="chubut_22",path=id_carpeta)

gs4_create(name="cordoba_22",sheets=df_cordoba_22)
drive_mv(file="cordoba_22",path=id_carpeta)

gs4_create(name="corrientes_22",sheets=df_corrientes_22)
drive_mv(file="corrientes_22",path=id_carpeta)

gs4_create(name="entre_rios_22",sheets=df_entre_rios_22)
drive_mv(file="entre_rios_22",path=id_carpeta)

gs4_create(name="formosa_22",sheets=df_formosa_22)
drive_mv(file="formosa_22",path=id_carpeta)

gs4_create(name="jujuy_22",sheets=df_jujuy_22)
drive_mv(file="jujuy_22",path=id_carpeta)

gs4_create(name="la_pampa_22",sheets=df_la_pampa_22)
drive_mv(file="la_pampa_22",path=id_carpeta)

gs4_create(name="la_rioja_22",sheets=df_la_rioja_22)
drive_mv(file="la_rioja_22",path=id_carpeta)

gs4_create(name="mendoza_22",sheets=df_mendoza_22)
drive_mv(file="mendoza_22",path=id_carpeta)

gs4_create(name="misiones_22",sheets=df_misiones_22)
drive_mv(file="misiones_22",path=id_carpeta)

gs4_create(name="neuquen_22",sheets=df_neuquen_22)
drive_mv(file="neuquen_22",path=id_carpeta)

gs4_create(name="rio_negro_22",sheets=df_rio_negro_22)
drive_mv(file="rio_negro_22",path=id_carpeta)

gs4_create(name="san_juan_22",sheets=df_san_juan_22)
drive_mv(file="san_juan_22",path=id_carpeta)

gs4_create(name="san_luis_22",sheets=df_san_luis_22)
drive_mv(file="san_luis_22",path=id_carpeta)

gs4_create(name="santa_cruz_22",sheets=df_santa_cruz_22)
drive_mv(file="santa_cruz_22",path=id_carpeta)

gs4_create(name="tdf_22",sheets=df_TDF_22)
drive_mv(file="tdf_22",path=id_carpeta)

gs4_create(name="tucuman_22",sheets=df_tucuman_22)
drive_mv(file="tucuman_22",path=id_carpeta)


id_caba_22<-drive_get("CABA_alícuota22")
test<-read_sheet(id_caba_22)
