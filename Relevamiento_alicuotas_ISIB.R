
library(tidyverse)
library(readxl)
library(openxlsx)
library(readr)
library(XML)
library(xml2)
library(RCurl)
library(rlist)
library(httr)
library(dplyr)
library(googlesheets4)
library(googledrive)

rm(list=ls())
gc()
setwd("C:/Users/Ministerio/Documents/alicuotas_ISIB/")



###Importación de las tablas de equivalencia AFIP - NAES - CUACM -------------
if(!file.exists("Bases_externas")) {
  dir.create("Bases_externas")
}

download.file(
  url = "https://www.ca.gov.ar/descargar/naes_anexos/NAES_Anexos%20I-II%20y%20III_RG_12-2017.xlsx", 
  destfile = "Bases_externas/NAES_CUACM.xlsx", mode='wb'
)

NAES_descripcion<- read_excel("Bases_externas/NAES_CUACM.xlsx", 
                              sheet = "AnexoI_NAES", skip=2)

CUACM_NAES<-read_excel("Bases_externas/NAES_CUACM.xlsx", 
                       sheet = "AnexoII_Equivalencia CUACM-NAES", skip=2)

AFIP_NAES<-read_excel("Bases_externas/NAES_CUACM.xlsx", 
                      sheet = "AnexoIII_Equivalencia AFIP-NAES", skip=2)

names(NAES_descripcion)<- c("codigo_NAES","descripcion","incluye","excluye")
names(CUACM_NAES)<- c("codigo_NAES","descripcion_NAES","codigo_CUACM","descripcion_CUACM")
names(AFIP_NAES)<- c("codigo_NAES","descripcion_NAES","codigo_AFIP","descripcion_AFIP")

llave_NAES_AFIP_CUACM <-  NAES_descripcion %>% 
  left_join(AFIP_NAES) %>%
  left_join(CUACM_NAES) #Este orden de fusión es importante, porque así hay un sólo valor faltante, servicios conexos de la minería 
#(que no existen en CUACM, pero sí en AFIP y NAES).

lista_NAES<-llave_NAES_AFIP_CUACM%>%
  select(c(codigo_NAES,descripcion))%>%
  mutate(codigo_NAES=ifelse(codigo_NAES<100000, paste0("0",as.character(codigo_NAES)), 
                            as.character(codigo_NAES))
  )%>%                                          
  distinct()

rm(NAES_descripcion,CUACM_NAES,AFIP_NAES)
#unlink("Bases_externas/NAES_CUACM.xlsx")
unlink("Bases_externas/",recursive = TRUE)  #Borra el archivo importado 

faltantes_llave<-llave_NAES_AFIP_CUACM%>%
  subset(is.na(codigo_CUACM) | is.na(codigo_AFIP))
head(faltantes_llave)
rm(faltantes_llave)


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
  output<-plyr::ldply(tables,data.frame,.id="cuadro") #Esto concatena todas las tablas en un solo df
  #Es importante no cargar la librería plyr, porque entra en conflicto con dplyr para, por ejemplo, rename()
}
setwd("tablas_ERREPAR/")
df_buenos_aires_22<-alicuotas_ERREPAR("buenos_aires_2022")
df_catamarca_22<-alicuotas_ERREPAR("catamarca_2022")
df_CABA_22<-alicuotas_ERREPAR("CABA_2022")
df_cordoba_22<-alicuotas_ERREPAR("cordoba_2022")
df_corrientes_22<-alicuotas_ERREPAR("corrientes_2022")
df_chaco_22<-alicuotas_ERREPAR("chaco_2_2022") #Tabla únicamente para contribuyentes locales
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
df_salta_22<-alicuotas_ERREPAR("salta_2_2022")
df_san_juan_22<-alicuotas_ERREPAR("san_juan_2022")
df_san_luis_22<-alicuotas_ERREPAR("san_luis_2022")
df_santa_cruz_22<-alicuotas_ERREPAR("santa_cruz_2022")
df_santa_fe_22<-alicuotas_ERREPAR("santa_fe_2022")
df_santiago_del_estero_22<-alicuotas_ERREPAR("santiago_del_estero_2022")
df_TDF_22<-alicuotas_ERREPAR("tdf_2022")
df_tucuman_22<-alicuotas_ERREPAR("tucuman_2022")

setwd("../")

gs4_auth() #Conección a la cuenta google

id_carpeta<-drive_get("Relevamiento_alicuotas")


##### Exportamos los cuadros sacados de ERREPAR, con códigos NAES 

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

gs4_create(name="salta_anexo1_22",sheets=df_salta_anexo1_22)
drive_mv(file="salta_anexo1_22",path=id_carpeta)


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

###### Funciones ---------
formateo_alicuotas<-function(input,cat_var,correc_max){
  output<-input%>%
    mutate(across(where(is.list),~ifelse(.x=="NULL", NA, #Ponemos como valores faltantes las alícuotas que tienen el valor "NULL"
                                         .x)), 
           across(where(is.list),~as.character(.x)),#Se importaron las alícuotas como listas, no caracteres; lo corregimos aquí
           across(everything(),~gsub("%","",.x)), #Sacamos los % de las alícuotas, así las podremos pasar a numérico
           across(starts_with(cat_var),~gsub(",",".",.x)), #Reemplazamos las comas por puntos en las alícuotas, así las podremos pasar a numérico
           es_numerica=ifelse(substr(start=1,stop=1,codigo_NAES) %in% c("0","1","2","3","4","5","6","7","8","9"), 1,
                              0) #Quitamos las observaciones que no corresponden a un código NAES definido
    )%>%
    subset(es_numerica==1)%>%
    select(-c(es_numerica))%>%
    mutate(across(starts_with(cat_var),~as.double(.x)), #Pasamos las alícuotas a numérico
           across(starts_with(cat_var),~ifelse(.x<correc_max, .x*100, #Se importaron algunas alícuotas, en vez de 10%, como 0,1. Se corrige aquí
                                               .x)
           )
    )%>%
    select(-c(cuadro))%>%# No es más necesaria la información del cuadro en que estaba el nomenclador
    distinct()#Hay algunos nomencladores repetidos por error de ERREPAR; los sacamos
} 

#Para la tabla comparativa, vamos a tomar siempre la alícuota más alta posible para cada actividad (en general grandes contribuyentes).
#Se puede hacer lo mismo con la más baja posible para cada actividad.

min_max<-function(input,variables,id_variable){ #Valores mínimos y máximos de una clase de variables, siguiendo un id
  var_ali<-as_tibble(input)%>%
    select(starts_with(variables))
  
  lista_alicuotas<-names(var_ali) #Creamos una lista con las variables que empiecen con "alicuota"
  
  output<-input%>%
    mutate(maximum=invoke(pmax,c(across(all_of(lista_alicuotas)),na.rm=TRUE)), #Valor máximo entre las variables que empiecen con "alicuota"
           minimum=invoke(pmin,c(across(all_of(lista_alicuotas)),na.rm=TRUE))#Valor máximo entre las variables que empiecen con "alicuota"
    )%>%
    group_by(get(id_variable))%>%
    summarise(min_name=min(minimum),
              max_name=max(maximum)
    )%>%
    ungroup()
}



######## Cuadro NAES IIBB, CABA------
id_CABA<-drive_get("CABA_alícuota22")
df_CABA_22<-read_sheet(ss=id_CABA) #Importamos cuadro modificado, con alícuota agregada
names(df_CABA_22)<-c("cuadro","codigo_NAES","descripcion","alicuota_1","alicuota_2","alicuota_3","fuente")

df_CABA_22<-formateo_alicuotas(df_CABA_22,"alicuota",0.2)


temp<-min_max(df_CABA_22,"alicuota","codigo_NAES")
names(temp)<-c("codigo_NAES","min_ali","max_ali") #No logramos poner nombres correctos en la función, así que los corregimos aquí afuera

df_CABA_NAES_22<-lista_NAES%>%
  left_join(temp)
head(df_CABA_NAES_22)

faltantes<-df_CABA_NAES_22%>%
  subset(is.na(max_ali))
head(faltantes)

rm(faltantes,temp,id_CABA)

drive_trash("CABA_NAES_22")
gs4_create(name="CABA_NAES_22",sheets=df_CABA_NAES_22)
drive_mv(file="CABA_NAES_22",path=id_carpeta)



######## Cuadro NAES IIBB, Buenos Aires------


id_buenos_aires<-drive_get("buenos_aires_alicuotas_22")
df_buenos_aires_22<-read_sheet(ss=id_buenos_aires) #Importamos cuadro modificado, con alícuota agregada
names(df_buenos_aires_22)<-c("cuadro","codigo_NAES","descripcion","borrar_1","borrar_2","alicuota_gran_c","alicuota_resto_c","alicuota_peque_c","alicuota_can","fuente")
view(df_buenos_aires_22)
df_buenos_aires_22<-df_buenos_aires_22%>%
  select(-c(borrar_1,borrar_2))%>%
  #Sacamos alícuotas exentas que no siguen el NAES
  subset(cuadro!="33" & cuadro!="34" & cuadro!="35" & cuadro!="36" & cuadro!="37" & cuadro!="38" & cuadro!="39" & cuadro!="40" & cuadro!="41" & cuadro!="42" & cuadro!="43" & cuadro!="44")%>%
  mutate(across(starts_with("alicuota"),~gsub("Exentas","0",.x)), #Ponemos en 0 las alícuotas exentas
         codigo_NAES=gsub("\\(3\\)","",codigo_NAES), #Quitamos  (3)
         codigo_NAES=gsub("\\(4\\)","",codigo_NAES), #Quitamos (4)
        )

df_buenos_aires_22<-formateo_alicuotas(df_buenos_aires_22,"alicuota",0.2)
temp<-min_max(df_buenos_aires_22,"alicuota","codigo_NAES")

names(temp)<-c("codigo_NAES","min_ali","max_ali") #No logramos poner nombres correctos en la función, así que los corregimos aquí afuera

df_buenos_aires_NAES_22<-lista_NAES%>%
  left_join(temp)
head(df_buenos_aires_NAES_22)

faltantes<-df_buenos_aires_NAES_22%>%
  subset(is.na(max_ali))%>%
  mutate(codigo_corto=substr(start=1,stop=5,codigo_NAES)) #Hay códigos NAES más generales para Buenos Aires, con sólo 5 dígitos

temp_faltantes<-temp%>%
  mutate(codigo_corto=substr(start=1,stop=5,codigo_NAES))%>%
  select(-c(codigo_NAES))%>%
  group_by(codigo_corto)%>%
  summarise(min_ali=min(min_ali), 
            max_ali=max(max_ali))%>%
  ungroup()


faltantes<-faltantes%>%
  select(-c(min_ali,max_ali))%>%
  left_join(temp_faltantes)%>%
  distinct()%>%
  select(-c(codigo_corto))

df_buenos_aires_NAES_22<-df_buenos_aires_NAES_22%>%
  subset(!is.na(max_ali))%>%
  rbind(faltantes)%>%
  arrange(codigo_NAES)

faltantes<-df_buenos_aires_NAES_22%>%
  subset(is.na(max_ali))
head(faltantes)
         
rm(faltantes,temp,temp_faltantes,id_buenos_aires)

drive_trash("Buenos_Aires_NAES_22")
gs4_create(name="Buenos_Aires_NAES_22",sheets=df_buenos_aires_NAES_22)
drive_mv(file="Buenos_Aires_NAES_22",path=id_carpeta)


######## Cuadro NAES IIBB, Chubut------

id_chubut<-drive_get("chubut_alicuota22")
df_chubut_22<-read_sheet(ss=id_chubut) #Importamos cuadro modificado, con alícuota agregada
names(df_chubut_22)<-c("cuadro","codigo_NAES","descripcion","alicuota_1","alicuota_2","alicuota_3")
df_chubut_22<-df_chubut_22%>% #Corregimos errores tipográficos de ERREPAR
  mutate(codigo_NAES=gsub("S","5",codigo_NAES), 
         codigo_NAES=gsub("Ó","0",codigo_NAES), 
         codigo_NAES=gsub("\\$","5",codigo_NAES), 
         codigo_NAES=ifelse(descripcion=="Emisión y retransmisión de radio", "601000", 
                            codigo_NAES))
df_chubut_22<-formateo_alicuotas(df_chubut_22,"alicuota",0.2)
temp<-min_max(df_chubut_22,"alicuota","codigo_NAES")

names(temp)<-c("codigo_NAES","min_ali","max_ali") #No logramos poner nombres correctos en la función, así que los corregimos aquí afuera

df_chubut_NAES_22<-lista_NAES%>%
  left_join(temp)
head(df_chubut_NAES_22)

faltantes<-df_chubut_NAES_22%>%
  subset(is.na(max_ali))
view(faltantes)

rm(temp,id_chubut,faltantes)

drive_trash("Chubut_NAES_22")
gs4_create(name="Chubut_NAES_22",sheets=df_chubut_NAES_22)
drive_mv(file="Chubut_NAES_22",path=id_carpeta)

######## Cuadro NAES IIBB, Córdoba------
id_cordoba<-drive_get("cordoba_alícuota22")
df_cordoba_22<-read_sheet(ss=id_cordoba)
names(df_cordoba_22)<-c("cuadro","codigo_NAES","descripcion","alicuota_1","alicuota_2","alicuota_3")
df_cordoba_22<-df_cordoba_22%>%
  mutate(codigo_NAES=gsub("\\(3\\)","",codigo_NAES), #Quitamos  (3)
         codigo_NAES=gsub("\\(4\\)","",codigo_NAES), #Quitamos (4))
         codigo_NAES=gsub("\\(5\\)","",codigo_NAES), #Quitamos (5))
         codigo_NAES=gsub("\\(6\\)","",codigo_NAES), #Quitamos (6))
         codigo_NAES=gsub("\\(7\\)","",codigo_NAES), #Quitamos (7))
         codigo_NAES=gsub("\\(8\\)","",codigo_NAES), #Quitamos (8))
         codigo_NAES=gsub("\\(9\\)","",codigo_NAES), #Quitamos (9))
         codigo_NAES=gsub("\\(10\\)","",codigo_NAES), #Quitamos (10))
         codigo_NAES=gsub("\\(11\\)","",codigo_NAES), #Quitamos (11))
         codigo_NAES=gsub("\\(12\\)","",codigo_NAES), #Quitamos (12))
         codigo_NAES=gsub("\\(13\\)","",codigo_NAES), #Quitamos (13))
         codigo_NAES=gsub("\\(14\\)","",codigo_NAES), #Quitamos (14))
         codigo_NAES=gsub("\\(15\\)","",codigo_NAES), #Quitamos (15))
         codigo_NAES=gsub("\\(16\\)","",codigo_NAES), #Quitamos (16))
         codigo_NAES=gsub("\\(17\\)","",codigo_NAES), #Quitamos (17))
         codigo_NAES=gsub("\\(18\\)","",codigo_NAES), #Quitamos (18))
         codigo_NAES=gsub("\\(19\\)","",codigo_NAES), #Quitamos (19))
         codigo_NAES=gsub("\\(20\\)","",codigo_NAES), #Quitamos (20))
         codigo_NAES=gsub("\\(21\\)","",codigo_NAES), #Quitamos (21))
         codigo_NAES=gsub("\\(22\\)","",codigo_NAES), #Quitamos (22))
         codigo_NAES=gsub("\\(23\\)","",codigo_NAES), #Quitamos (23))
         cod_num=as.integer(codigo_NAES), 
         codigo_NAES=ifelse(cod_num<100000, paste0("0",cod_num), 
                            codigo_NAES), 
         codigo_NAES=ifelse(descripcion=="Perforación de pozos de agua", "422100", 
                            codigo_NAES), 
         codigo_NAES=ifelse(descripcion=="Construcción, reforma y reparación de redes distribución de electricidad, gas, agua, telecomunicaciones y de otros servicios públicos", "422200", 
                            codigo_NAES),
         codigo_NAES=ifelse(descripcion=="Servicios inmobiliarios realizados por cuenta propia, con bienes urbanos propios o arrendados n.c.p.", "681098", 
                            codigo_NAES)
         )%>%
  select(-c(cod_num))

df_cordoba_22<-formateo_alicuotas(df_cordoba_22,"alicuota",0.2)
temp<-min_max(df_cordoba_22,"alicuota","codigo_NAES")

names(temp)<-c("codigo_NAES","min_ali","max_ali") #No logramos poner nombres correctos en la función, así que los corregimos aquí afuera



df_cordoba_NAES_22<-lista_NAES%>%
  left_join(temp)
head(df_cordoba_NAES_22)

faltantes<-df_cordoba_NAES_22%>%
  subset(is.na(max_ali))
view(faltantes)

rm(temp,id_cordoba,faltantes)

drive_trash("Cordoba_NAES_22")
gs4_create(name="Cordoba_NAES_22",sheets=df_cordoba_NAES_22)
drive_mv(file="Cordoba_NAES_22",path=id_carpeta)

######## Cuadro NAES IIBB, Corrientes------


id_corrientes<-drive_get("corrientes_alícuota22")
df_corrientes_22<-read_sheet(ss=id_corrientes)
df_corrientes_22<-df_corrientes_22[,c(1,8,9,10,11,12,13)] #No nos interesan los códigos de actividad locales
names(df_corrientes_22)<-c("cuadro","codigo_NAES","descripcion","alicuota","minimo","regimen","regimen_desc")
df_corrientes_22<-df_corrientes_22%>%
  mutate(cod_num=as.integer(codigo_NAES), 
         codigo_NAES=ifelse(cod_num<100000, paste0("0",cod_num), 
                   codigo_NAES), 
         alicuota=gsub("\\_","",alicuota), 
        )

df_corrientes_22<-formateo_alicuotas(df_corrientes_22,"alicuota",0.2)
temp<-min_max(df_corrientes_22,"alicuota","codigo_NAES")
names(temp)<-c("codigo_NAES","min_ali","max_ali") #No logramos poner nombres correctos en la función, así que los corregimos aquí afuera

df_corrientes_NAES_22<-lista_NAES%>%
  left_join(temp)%>%
  mutate(min_ali=ifelse(codigo_NAES=="949920", 0, #Servicios de consorcio no están alcanzados por ISIB Corrientes
                        min_ali), 
         max_ali=ifelse(codigo_NAES=="949920", 0, 
                        max_ali)
         )

faltantes<-df_corrientes_NAES_22%>%
  subset(is.na(max_ali))
view(faltantes)

rm(temp,id_corrientes,faltantes)


drive_trash("Corrientes_NAES_22")
gs4_create(name="Corrientes_NAES_22",sheets=df_corrientes_NAES_22)
drive_mv(file="Corrientes_NAES_22",path=id_carpeta)


######## Cuadro NAES IIBB, Entre Ríos------

id_entre_rios<-drive_get("entre_rios_22_alicuota")
df_entre_rios_22<-read_sheet(ss=id_entre_rios)
df_entre_rios_22<-df_entre_rios_22[,c(1,2,3,12,13,14,15)] #No tomamos en cuenta el anexo II, nomenclador NAES-ATER
names(df_entre_rios_22)<-c("cuadro","codigo_NAES","descripcion","alicuota_micro","alicuota_med1","alicuota_med2","alicuota_grande")

df_entre_rios_22<-df_entre_rios_22%>%
  subset(cuadro!=5)  #No tomamos en cuenta el anexo II, nomenclador NAES-ATER

df_entre_rios_22<-formateo_alicuotas(df_entre_rios_22,"alicuota",0.2)
temp<-min_max(df_entre_rios_22,"alicuota","codigo_NAES")
names(temp)<-c("codigo_NAES","min_ali","max_ali") #No logramos poner nombres correctos en la función, así que los corregimos aquí afuera


df_entre_rios_NAES_22<-lista_NAES%>%
  left_join(temp)

faltantes<-df_entre_rios_NAES_22%>%
  subset(is.na(max_ali))
head(faltantes)

rm(temp,id_entre_rios,faltantes)

drive_trash("Entre_Rios_NAES_22")
gs4_create(name="Entre_Rios_NAES_22",sheets=df_entre_rios_NAES_22)
drive_mv(file="Entre_Rios_NAES_22",path=id_carpeta)


######## Cuadro NAES IIBB, Formosa------


id_formosa<-drive_get("formosa_22_alicuota")
df_formosa_22<-read_sheet(ss=id_formosa)
names(df_formosa_22)<- c("cuadro","codigo_NAES","descripcion","tratamiento","alicuota","tratamiento_2","incluye","excluye")

df_formosa_22<-df_formosa_22%>%
  group_by(incluye)%>%
  fill(codigo_NAES)%>%
  fill(codigo_NAES,.direction="up")%>%  #Hay que expandir el código NAES a tratamientos en que no estaba incluido
  ungroup()%>%
  mutate(cod_num=as.integer(codigo_NAES), 
         codigo_NAES=ifelse(cod_num<100000, paste0("0",cod_num), 
                            codigo_NAES)
         )

df_formosa_22<-formateo_alicuotas(df_formosa_22,"alicuota",0.2)
temp<-min_max(df_formosa_22,"alicuota","codigo_NAES")
names(temp)<-c("codigo_NAES","min_ali","max_ali") #No logramos poner nombres correctos en la función, así que los corregimos aquí afuera

df_formosa_NAES_22<-lista_NAES%>%
  left_join(temp)

faltantes<-df_formosa_NAES_22%>%
  subset(is.na(max_ali))
head(faltantes)

rm(temp,id_formosa,faltantes)

drive_trash("Formosa_NAES_22")
gs4_create(name="Formosa_NAES_22",sheets=df_formosa_NAES_22)
drive_mv(file="Formosa_NAES_22",path=id_carpeta)


######## Cuadro NAES IIBB, Jujuy------


id_jujuy<-drive_get("jujuy_22_alicuota")
df_jujuy_22<-read_sheet(ss=id_jujuy)
names(df_jujuy_22)<-c("cuadro","codigo_NAES","alicuota_gen","alicuota_esp","alicuota_2","alicuota_3","alicuota_4","alicuota_5","alicuota_6","alicuota_7","alicuota_8")

df_jujuy_22<-formateo_alicuotas(df_jujuy_22,"alicuota",0.2)
temp<-min_max(df_jujuy_22,"alicuota","codigo_NAES")
names(temp)<-c("codigo_NAES","min_ali","max_ali") #No logramos poner nombres correctos en la función, así que los corregimos aquí afuera


df_jujuy_NAES_22<-lista_NAES%>%
  left_join(temp)

faltantes<-df_jujuy_NAES_22%>%
  subset(is.na(max_ali))%>%
  mutate(codigo_corto=substr(start=1,stop=5,codigo_NAES)) #Hay códigos NAES más generales para Buenos Aires, con sólo 5 dígitos

temp_faltantes<-temp%>%
  mutate(codigo_corto=substr(start=1,stop=5,codigo_NAES))%>%
  select(-c(codigo_NAES))%>%
  group_by(codigo_corto)%>%
  summarise(min_ali=min(min_ali), 
            max_ali=max(max_ali))%>%
  ungroup()


faltantes<-faltantes%>%
  select(-c(min_ali,max_ali))%>%
  left_join(temp_faltantes)%>%
  distinct()%>%
  select(-c(codigo_corto))

df_jujuy_NAES_22<-df_jujuy_NAES_22%>%
  subset(!is.na(max_ali))%>%
  rbind(faltantes)%>%
  arrange(codigo_NAES)

faltantes<-df_jujuy_NAES_22%>%
  subset(is.na(max_ali))
head(faltantes)


rm(temp,id_jujuy,faltantes)

drive_trash("Jujuy_NAES_22")
gs4_create(name="Jujuy_NAES_22",sheets=df_jujuy_NAES_22)
drive_mv(file="Jujuy_NAES_22",path=id_carpeta)


######## Cuadro NAES IIBB, La Pampa------


id_la_pampa<-drive_get("la_pampa_22_alicuota")
df_la_pampa_22<-read_sheet(ss=id_la_pampa)
names(df_la_pampa_22)<-c("cuadro","codigo_NAES","descripcion","alicuota_a","alicuota_b","fuente")

df_la_pampa_22<-df_la_pampa_22%>%
  mutate(codigo_NAES=gsub("\\(1\\)","",codigo_NAES), #Quitamos  (1)
         cod_num=as.integer(codigo_NAES), 
         codigo_NAES=ifelse(cod_num<100000, paste0("0",cod_num), 
                            codigo_NAES),
         #Por art. 33 Ley 3402, se agrava la alícuota de la columna a) en un 30%  si se pasa un nivel de facturación, y si no hay una alícuota 
         #prevista en la columna b)
         alicuota_num=as.double(gsub("\\,","\\.",alicuota_a)),
         alicuota_num=alicuota_num*1.3,
         alicuota_num=as.character(gsub("\\.","\\,",alicuota_num)),
         alicuota_c=ifelse(is.na(alicuota_b) & cuadro=="2", as.character(alicuota_num), 
                           alicuota_a)
  )
df_la_pampa_22<-formateo_alicuotas(df_la_pampa_22,"alicuota",0.2)
temp<-min_max(df_la_pampa_22,"alicuota","codigo_NAES")
names(temp)<-c("codigo_NAES","min_ali","max_ali") #No logramos poner nombres correctos en la función, así que los corregimos aquí afuera

df_la_pampa_NAES_22<-lista_NAES%>%
  left_join(temp)

faltantes<-df_la_pampa_NAES_22%>%
  subset(is.na(max_ali))
head(faltantes)

df_la_pampa_NAES_22<-df_la_pampa_NAES_22%>%
  mutate(min_ali=ifelse(is.na(min_ali), 3, #Las actividades que no tengan tratamiento especial en la ley impositiva tienen 3%
                        min_ali), 
         max_ali=ifelse(is.na(max_ali), 3.9, #Agravada en 30% para las empresas más grandes 
                        max_ali)
         )
head(df_la_pampa_NAES_22)
rm(temp,id_la_pampa,faltantes)

drive_trash("La_Pampa_NAES_22")
gs4_create(name="La_Pampa_NAES_22",sheets=df_la_pampa_NAES_22)
drive_mv(file="La_Pampa_NAES_22",path=id_carpeta)


######## Cuadro NAES IIBB, La Rioja------


id_la_rioja<-drive_get("la_rioja_alícuota22")
df_la_rioja_22<-read_sheet(ss=id_la_rioja)
view(df_la_rioja_22)
names(df_la_rioja_22)<-c("cuadro","codigo_NAES","descripcion","alicuota_1","alicuota_2","alicuota_3","min_anual","fijo","fuente")
head(df_la_rioja_22)

df_la_rioja_22<-formateo_alicuotas(df_la_rioja_22,"alicuota",0.2)
temp<-min_max(df_la_rioja_22,"alicuota","codigo_NAES")
names(temp)<-c("codigo_NAES","min_ali","max_ali") #No logramos poner nombres correctos en la función, así que los corregimos aquí afuera

df_la_rioja_NAES_22<-lista_NAES%>%
  left_join(temp)%>% #Hay algunos códigos faltantes, por error de carga (esquila) o por no estar mencionados (generación energía eléctrica)
  mutate(min_ali=ifelse(codigo_NAES=="016230",2.5, 
                        ifelse(codigo_NAES=="351110" | codigo_NAES=="351120", 2.5, 
                               min_ali)), 
         max_ali=ifelse(codigo_NAES=="016230",4, 
                        ifelse(codigo_NAES=="351110" | codigo_NAES=="351120", 2.5, #Le ponemos la alícuota general
                               max_ali))
        )

faltantes<-df_la_rioja_NAES_22%>%
  subset(is.na(max_ali))
head(faltantes)


rm(temp,id_la_rioja,faltantes)

drive_trash("La_Rioja_NAES_22")
gs4_create(name="La_Rioja_NAES_22",sheets=df_la_rioja_NAES_22)
drive_mv(file="La_Rioja_NAES_22",path=id_carpeta)


######## Cuadro NAES IIBB, Mendoza------


id_mendoza<-drive_get("mendoza_alícuota22")
df_mendoza_22<-read_sheet(ss=id_mendoza)
view(df_mendoza_22)
names(df_mendoza_22)<-c("cuadro","codigo_NAES","descripcion","alicuota","tamanio","fuente")

df_mendoza_22<-df_mendoza_22%>%
  mutate(cod_num=as.integer(codigo_NAES), 
         codigo_NAES=ifelse(cod_num<100000, paste0("0",cod_num), 
                            codigo_NAES),
         across(everything(),~gsub("%","",.x)), #Sacamos los % de las alícuotas, así las podremos pasar a numérico
#Varias actividades tienen alícuotas reducidas sólo si cumplen con ciertas condiciones, si no, caen en la general. Corregimos el dato aquí
         alicuota_agravada=ifelse(grepl("(1)",descripcion,fixed=TRUE),"0,75", #Agrícola-ganadera, general
                              ifelse(grepl("(4)",descripcion,fixed=TRUE),
                                     ifelse(cod_num>=101011 & cod_num<=370000,"1,5", #Manufacturera, general
                                            ifelse(cod_num>=410011 & cod_num<=439990, "2,5",#Construcción, general
                                                  alicuota)
                                            ),
                                    alicuota)
                                  ),
         aumento=ifelse(grepl("(5)",descripcion,fixed=TRUE), 1, #En algunos casos, agrega 1% o 1,5% a la alícuota
                        ifelse(grepl("(13)", descripcion, fixed=TRUE), 1.5, 
                              0)
                       ),
         aumento_2=ifelse(tamanio==1, 0.5, #Para casi todas las actividades, hay un esquema de sobrealícuotas según facturación
                          ifelse(tamanio==2, 1, 
                                 0)
                          ),
         alicuota_num=gsub(",",".",alicuota_agravada),
         alicuota_max=as.double(alicuota_num)+aumento + aumento_2
        )
view(df_mendoza_22)


df_mendoza_22<-formateo_alicuotas(df_mendoza_22,"alicuota",0.3)
temp<-min_max(df_mendoza_22,"alicuota","codigo_NAES")
names(temp)<-c("codigo_NAES","min_ali","max_ali") #No logramos poner nombres correctos en la función, así que los corregimos aquí afuera


df_mendoza_NAES_22<-lista_NAES%>%
  left_join(temp)

faltantes<-df_mendoza_NAES_22%>%
  subset(is.na(max_ali))
head(faltantes)

rm(temp,id_mendoza,faltantes)

drive_trash("Mendoza_NAES_22")
gs4_create(name="Mendoza_NAES_22",sheets=df_mendoza_NAES_22)
drive_mv(file="Mendoza_NAES_22",path=id_carpeta)



######## Cuadro NAES IIBB, Misiones------

id_misiones<-drive_get("misiones_22_alicuota")
df_misiones_22<-read_sheet(ss=id_misiones)

names(df_misiones_22)<- c("cuadro","codigo_ley","codigo_NAES","codigo_provincial","descripcion","alicuota","fuente")
df_misiones_22<-df_misiones_22%>%
  mutate(across(starts_with("alicuota"),~gsub("Exento","0",.x)), #Ponemos en 0 las alícuotas exentas
         across(starts_with("alicuota"),~gsub("\\(1\\)","",.x)), #Quitamos  (1)
         across(starts_with("alicuota"),~gsub("\\(3\\)","",.x)), #Quitamos  (3)
         across(starts_with("alicuota"),~gsub("\\(4\\)","",.x)), #Quitamos  (4)
        )
df_misiones_22<-formateo_alicuotas(df_misiones_22,"alicuota",0.3)
temp<-min_max(df_misiones_22,"alicuota","codigo_NAES")
names(temp)<-c("codigo_NAES","min_ali","max_ali") #No logramos poner nombres correctos en la función, así que los corregimos aquí afuera

lista_servicios_petroleros<-c("091001","091002","091003","091009")
lista_venta_mayor_combustibles<-c("466111","466112","466119","466122","466123","466129")
lista_venta_menor_combustibles<-c("473001","473002","473003","477461","477462","920001","920009")
lista_transporte<-c("491201","491209")
lista_libros<-c("581100","581300")

df_misiones_NAES_22<-lista_NAES%>%
  left_join(temp)%>%
  mutate(min_ali=ifelse(codigo_NAES %in% lista_servicios_petroleros, 5,
                        ifelse(codigo_NAES %in% lista_venta_mayor_combustibles, 4.5,
                               ifelse(codigo_NAES %in% lista_venta_menor_combustibles, 8,
                                      ifelse(codigo_NAES=="476121", 0, 
                                             ifelse(codigo_NAES %in% lista_transporte, 2, 
                                                    ifelse(codigo_NAES %in% lista_libros, 1.5, 
                                                           min_ali)
                                                    )
                                            )
                                    )
                               )
                        ),
         max_ali=ifelse(codigo_NAES %in% lista_servicios_petroleros, 5,
                        ifelse(codigo_NAES %in% lista_venta_mayor_combustibles, 4.5,
                               ifelse(codigo_NAES %in% lista_venta_menor_combustibles, 8,
                                      ifelse(codigo_NAES=="476121", 0, 
                                             ifelse(codigo_NAES %in% lista_transporte, 2, 
                                                    ifelse(codigo_NAES %in% lista_libros, 1.5, 
                                                           max_ali)
                                                    )
                                             )
                                     )
                              )
                       )
         )

faltantes<-df_misiones_NAES_22%>%
  subset(is.na(max_ali))
head(faltantes)

rm(temp,id_misiones,faltantes,list=ls(pattern="lista_"))


drive_trash("Misiones_NAES_22")
gs4_create(name="Misiones_NAES_22",sheets=df_misiones_NAES_22)
drive_mv(file="Misiones_NAES_22",path=id_carpeta)


######## Cuadro NAES IIBB, Neuquén------

id_neuquen<-drive_get("neuquen_22_alicuotas")
df_neuquen_22<-read_sheet(ss=id_neuquen)
names(df_neuquen_22)<- c("cuadro","codigo_NAES","descripcion","alicuota","alicuota_2","alicuota_3","alicuota_4","alicuota_5","fuente")
head(df_neuquen_22)
df_neuquen_22<-df_neuquen_22%>%
  mutate(alicuota=ifelse(cuadro=="4", 0.025, 
                         ifelse(cuadro=="6",0.055,
                                ifelse(cuadro=="12", 0.07,
                                       ifelse(cuadro=="13", 0.035,alicuota)
                                       )
                                )
                        ), 
         alicuota=ifelse(codigo_NAES=="612000", 0.065, 
                         alicuota),
         across(starts_with("alicuota"),~gsub("Exento","0",.x)) #Ponemos en 0 las alícuotas exentas
         )

df_neuquen_22<-formateo_alicuotas(df_neuquen_22,"alicuota",0.3)
temp<-min_max(df_neuquen_22,"alicuota","codigo_NAES")
names(temp)<-c("codigo_NAES","min_ali","max_ali") #No logramos poner nombres correctos en la función, así que los corregimos aquí afuera


df_neuquen_NAES_22<-lista_NAES%>%
  left_join(temp)%>%
  mutate(min_ali=ifelse(codigo_NAES=="161001" | codigo_NAES=="161002", 1.5, 
                    ifelse(codigo_NAES=="464910", 5, 
                       ifelse(codigo_NAES=="476121", 0, 
                          min_ali)
                           )
                     ), 
         max_ali=ifelse(codigo_NAES=="161001" | codigo_NAES=="161002", 1.5, 
                        ifelse(codigo_NAES=="464910", 5, 
                               ifelse(codigo_NAES=="476121", 0, 
                                      max_ali)
                             )
                        ) 
         )

faltantes<-df_neuquen_NAES_22%>%
  subset(is.na(max_ali))
head(faltantes)

rm(temp,id_neuquen,faltantes)


drive_trash("Neuquen_NAES_22")
gs4_create(name="Neuquen_NAES_22",sheets=df_neuquen_NAES_22)
drive_mv(file="Neuquen_NAES_22",path=id_carpeta)




######## Cuadro NAES IIBB, Río Negro------


id_rio_negro<-drive_get("rio_negro_22_alicuota")
df_rio_negro_22<-read_sheet(ss=id_rio_negro)
names(df_rio_negro_22)<-c("cuadro","codigo_NAES","descripcion","alicuota","fuente")

df_rio_negro_22<-df_rio_negro_22%>%
  mutate(codigo_NAES=gsub("/0","",codigo_NAES), #Sacamos /0, /1 y /2 del código NAES.
         codigo_NAES=gsub("/1","",codigo_NAES), 
         codigo_NAES=gsub("/3","",codigo_NAES), 
         )


df_rio_negro_22<-formateo_alicuotas(df_rio_negro_22,"alicuota",0.3)
temp<-min_max(df_rio_negro_22,"alicuota","codigo_NAES")
names(temp)<-c("codigo_NAES","min_ali","max_ali") #No logramos poner nombres correctos en la función, así que los corregimos aquí afuera


df_rio_negro_NAES_22<-lista_NAES%>%
  left_join(temp)

faltantes<-df_rio_negro_NAES_22%>%
  subset(is.na(max_ali))
head(faltantes)


rm(temp,id_rio_negro,faltantes)

drive_trash("Rio_Negro_NAES_22")
gs4_create(name="Rio_Negro_NAES_22",sheets=df_rio_negro_NAES_22)
drive_mv(file="Rio_Negro_NAES_22",path=id_carpeta)


######## Cuadro NAES IIBB, Salta------


##Para Salta, hay dos anexos tarifarios: contribuyentes locales (anexo I) y de convenio multilateral (anexo II)
#Para contribuyente local, la tabla es relativamente simple y está en ERREPAR; para convenio multilateral, es un pdf de 219 
#páginas que ni siquiera está con texto seleccionable. Dejamos por lo tanto este anexo para una siguiente etapa

df_salta_anexo1_22<-df_salta_22[,-c(2,3)]%>%  #Nivel de 1 y 2 dígitos que no nos interesan
  subset(!(is.na(V5)&is.na(V6)&is.na(V7)&is.na(V8)&is.na(V9)&is.na(V10))) #Líneas sin alícuotas informadas
names(df_salta_anexo1_22)<-c("cuadros","codigo_NAES","actividad","general_IVA","general_monotributo","especial","exentos","profesionales_uni","consumidor_final")
df_salta_anexo1_22<-df_salta_anexo1_22[-1,]
df_salta_anexo1_22<-df_salta_anexo1_22%>%
  mutate(NAES_faltante=ifelse(substr(codigo_NAES,start=1,stop=1) %in% c("0","1","2","3","4","5","6","7","8","9"),0,
                              ifelse(substr(codigo_NAES,start=1,stop=1)=="O", 0, #Algunos códigos empiezan con "Obs:"
                                     1)
  )
  )%>%
  subset(NAES_faltante==0)%>%
  select(-c(NAES_faltante))%>%
  mutate(fuente="Anexo I Res. Gen. 16/2022 DGR Salta")


###Las alícuotas para contribuyentes de convenio multilateral están en un pdf, que pasamos a excel con ilovepdf

read_excel_allsheets <- function(filename, tibble = FALSE) { #Función tomada de https://stackoverflow.com/questions/12945687/read-all-worksheets-in-an-excel-workbook-into-an-r-list-with-data-frames
  # I prefer straight data.frames
  # but if you like tidyverse tibbles (the default with read_excel)
  # then just pass tibble = TRUE
  sheets <- readxl::excel_sheets(filename)
  x <- lapply(sheets, function(X) readxl::read_excel(filename, sheet = X))
  if(!tibble) x <- lapply(x, as.data.frame)
  names(x) <- sheets
  x
}
#substrRight <- function(x, n){
#  substr(x, start=nchar(x)-n+1, stop=nchar(x)-n+1)
#}

table_list<-read_excel_allsheets("RG_16-2022_SALTA_ANEXOII.xlsx")
tables <- list.clean(table_list, fun = is.null, recursive = FALSE) # Esta instrucción es para quedarse sólo con las tablas 
#n.rows <- unlist(lapply(tables, function(t) dim(t)[1]))
#cuadro_mas_largo<-tables[[which.max(n.rows)]]
n.tables<-length(tables)
tables<-setNames(tables,c(1:n.tables)) #Cuadros renombrados según orden de aparición en la página

#tables<-lapply(tables,function(x) dplyr::mutate(x,mergeid=row_number())
#)
df_salta_anexo2_22<-plyr::ldply(tables,data.frame,.id="cuadro") #Esto concatena todas las tablas en un solo df

df_codigos<-df_salta_anexo2_22%>%
  select(starts_with("ANEXO") | starts_with("X"))%>%
  mutate(mergeid=row_number())

df_no_codigos<-df_salta_anexo2_22%>%
  select(!starts_with("ANEXO") & !starts_with("X"))%>%
  mutate(mergeid=row_number())

names(df_no_codigos)<-c("cuadro","descripcion","incluye","excluye","alicuota_1","alicuota_2","alicuota_3","alicuota_4","alicuota_5","alicuota_6","alicuota_7","alicuota_8","mergeid")
names(df_codigos)<-c("cod_1","cod_2","cod_3","cod_4","cod_5","cod_6","cod_7","cod_8","cod_9","cod_10","cod_11","cod_12","cod_13","cod_14","cod_15","cod_16","cod_17","cod_18","cod_19","mergeid")
#,1032,1041
lista_a_mantener<-c(871,952,963,997,1009,1034,1035,1070,1381,1413,1442,1460,1472,1475,1573,1576,1579,1584,1596,1600,1704,1852,1854,1890,1899,1918,1924,1927,1956,1960,1961,2045,2137)
lista_a_quitar<-c(1018,1020,1049,1250,1032,1041,1420,1421,1571,1572,1574,1577,1595,1598,1855,1889,2061)
df_codigos<-df_codigos%>%
  mutate(concatenado=ifelse(!is.na(cod_1),cod_1,
                            ifelse(!is.na(cod_2),cod_2,
                                   ifelse(!is.na(cod_3),cod_3,
                                          ifelse(!is.na(cod_4),cod_4,
                                                 ifelse(!is.na(cod_5),cod_5,
                                                        ifelse(!is.na(cod_6),cod_6,
                                                               ifelse(!is.na(cod_7),cod_7,
                                                                      ifelse(!is.na(cod_8),cod_8,
                                                                             ifelse(!is.na(cod_9),cod_9,
                                                                                    ifelse(!is.na(cod_10),cod_10,
                                                                                           ifelse(!is.na(cod_11),cod_11,
                                                                                                  ifelse(!is.na(cod_12),cod_12,
                                                                                                         ifelse(!is.na(cod_13),cod_13,
                                                                                                                ifelse(!is.na(cod_14),cod_14,
                                                                                                                       ifelse(!is.na(cod_15),cod_15,
                                                                                                                              ifelse(!is.na(cod_16),cod_16,
                                                                                                                                     ifelse(!is.na(cod_17),cod_17,
                                                                                                                                            ifelse(!is.na(cod_18),cod_18,
                                                                                                                                                   cod_19)
                                                                                                                                     )
                                                                                                                              )
                                                                                                                       )
                                                                                                                )
                                                                                                         )
                                                                                                  )
                                                                                           )
                                                                                    )
                                                                             )
                                                                      )
                                                               )
                                                        )
                                                 )
                                          )
                                   )
                            )
                    )
         )%>%
#  subset(!is.na(concatenado))%>%
  select(c(concatenado,mergeid))%>%
  left_join(df_no_codigos)%>%
  mutate(es_codigo=ifelse(grepl("[0-9]",concatenado), 1, 
                          0), 
         sin_alicuota=ifelse(grepl("[0-9]",alicuota_1),0, 
                             ifelse(grepl("[0-9]",alicuota_2),0, 
                                    ifelse(grepl("[0-9]",alicuota_3),0, 
                                           ifelse(grepl("[0-9]",alicuota_4),0,
                                                  ifelse(grepl("[0-9]",alicuota_5),0, 
                                                         ifelse(grepl("[0-9]",alicuota_6),0,
                                                                ifelse(grepl("[0-9]",alicuota_7),0,
                                                                       ifelse(grepl("[0-9]",alicuota_8),0,
                                                                              1)
                                                                )
                                                         )
                                                  )
                                           )
                                    )
                             )
                          ), 
         sin_descripcion=ifelse(is.na(descripcion) | (is.na(incluye) & is.na(excluye)), 1, 
                                0), 
         verificar=ifelse(!is.na(descripcion) & is.na(incluye) & is.na(excluye),1, 
                          0),
         sin_descripcion=ifelse(es_codigo==0 & sin_alicuota==1, 1, 
                                ifelse(verificar==1, 0, sin_descripcion)
                                ), 
         mantener_lineas=ifelse(mergeid%in% lista_a_mantener, 1,
                                ifelse(mergeid %in% lista_a_quitar,2,
                                       0)
                                )
  )

        # sin_alicuota_2=ifelse(grepl("[0-9]",across(starts_with("alicuota"))), 1,  Algún equivalente, para ver que ningún alicuota sea numérico? SEGUIR AQUI
         #                      0),
#         sin_alicuota=ifelse(is.na(alicuota_1) & is.na(alicuota_2)& is.na(alicuota_3)& is.na(alicuota_4)& is.na(alicuota_5)& is.na(alicuota_6)& is.na(alicuota_7)& is.na(alicuota_8)
 #                            , 1, 0)
  #       )


df_codigos_2<-df_codigos%>%
  subset(mantener_lineas!=2 & (mantener_lineas==1 | (
        sin_descripcion==0  & (sin_alicuota==0 | (sin_alicuota==1 & es_codigo==1))
        )))%>%
  select(-c(mergeid,verificar,es_codigo,sin_alicuota,sin_descripcion,cuadro,concatenado))%>%
  mutate(mergeid=row_number())

lista_aduana<-c("523011","523019","523020","523031")
df_salta_NAES_22<-lista_NAES%>%
  mutate(mergeid=row_number())%>%
  rename(descripcion_posta=descripcion)%>%
  left_join(df_codigos_2)%>%
  mutate(alicuota_6=ifelse(codigo_NAES %in% lista_aduana, 6, 
                           alicuota_6), 
         across(starts_with("alicuota"),~gsub("exenta","0",.x)), #Ponemos en 0 las alícuotas exentas
         across(starts_with("alicuota"),~gsub("exento","0",.x)), #Ponemos en 0 las alícuotas exentas
         across(starts_with("alicuota"),~gsub(",",".",.x)), #Pasamos las comas a puntos
         across(starts_with("alicuota"),~gsub("o","",.x)), #Corregimos errores de OCR
         across(starts_with("alicuota"),~gsub("O","",.x)), #Corregimos errores de OCR
         across(starts_with("alicuota"),~gsub("p","",.x)), #Corregimos errores de OCR
         across(starts_with("alicuota"),~gsub('"\\*',"",.x)),#Corregimos errores de OCR
         across(starts_with("alicuota"),~gsub('%',"",.x)),  #Corregimos errores de OCR
         across(starts_with("alicuota"),~gsub("'","",.x)),  #Corregimos errores de OCR
         across(starts_with("alicuota"),~gsub("Y","",.x)),  #Corregimos errores de OCR
         across(starts_with("alicuota"),~gsub("›","",.x)),  #Corregimos errores de OCR
         across(starts_with("alicuota"),~gsub(" ","",.x)),  #Corregimos errores de OCR
         across(starts_with("alicuota"),~gsub("096","0",.x)),  #Corregimos errores de OCR
         across(starts_with("alicuota"),~as.double(.x)),
         across(starts_with("alicuota"),~ifelse(.x<0.3, .x*100, #Alícuotas en formato
                                                .x))
         
         
       #  across(starts_with("alicuota"),~gsub("[[:punct:]]","",.x))
         
         #cientifico=ifelse(grepl("E",alicuota_1),1,
          #                 ifelse(grepl("E",alicuota_2),1,
           #                       ifelse(grepl("E",alicuota_3),1,
            #                             ifelse(grepl("E",alicuota_4),1,
             #                                   ifelse(grepl("E",alicuota_5),1,
              #                                         ifelse(grepl("E",alicuota_6),1,
               #                                               ifelse(grepl("E",alicuota_7),1,
                #                                                     ifelse(grepl("E",alicuota_8),1,
                 #                                                           0)
                  #                                            )
                   #                                    )
                    #                            )
                     #                    )
                      #            )
                       #       )
                        # )
         )



temp<-min_max(df_salta_NAES_22,"alicuota","codigo_NAES")
names(temp)<-c("codigo_NAES","min_ali","max_ali") #No logramos poner nombres correctos en la función, así que los corregimos aquí afuera
df_salta_NAES_22<-temp

faltantes<-df_salta_NAES_22%>%
  subset(is.na(max_ali))
view(faltantes)

drive_trash("faltantes_Salta_22")
gs4_create(name="faltantes_Salta_22",sheets=faltantes)
drive_mv(file="faltantes_Salta_22",path=id_carpeta)  

#Importamos el sheet con las alícuotas completadas

id_faltantes_salta<-drive_get("faltantes_Salta_completado_22")
faltantes_corr<-read_sheet(ss=id_faltantes_salta)
names(faltantes_corr)<-c("codigo_NAES","alicuota_1","alicuota_2","alicuota_3","alicuota_4")
faltantes_corr<-faltantes_corr%>%
  mutate(cuadro="1", 
         codigo_NAES=gsub("[^0-9.-]", "", codigo_NAES), 
         codigo_NAES=substr(start=1,stop=6,codigo_NAES))
faltantes_corr<-formateo_alicuotas(faltantes_corr,"alicuota",0.3)

faltantes_corr<-min_max(faltantes_corr,"alicuota","codigo_NAES")
names(faltantes_corr)<-c("codigo_NAES","min_ali","max_ali") #No logramos poner nombres correctos en la función, así que los corregimos aquí afuera

view(faltantes_corr)

faltantes_no<-df_salta_NAES_22%>%
  subset(!is.na(max_ali))

df_salta_NAES_22<- rbind(faltantes_no,faltantes_corr)%>%
  arrange(codigo_NAES)%>%
  distinct()

drive_trash("Salta_NAES_22")
gs4_create(name="Salta_NAES_22",sheets=df_salta_NAES_22)
drive_mv(file="Salta_NAES_22",path=id_carpeta) 

rm(temp,id_salta,id_faltantes_salta,list=ls(pattern="faltantes"),df_codigos,df_no_codigos,df_codigos_2)

######## Cuadro NAES IIBB, San Juan------

### En San Juan, el adicional Lote Hogar Ley 5287 le agrega 20% al ISIB efectivamente pagado, destinado a erradicar villas de emergencia. 

id_san_juan<-drive_get("san_juan_alícuota22")
df_san_juan_22<-read_sheet(ss=id_san_juan)
names(df_san_juan_22)<-c("cuadro","codigo_NAES","descripcion","alicuota","nota","fuente")

df_san_juan_22<-formateo_alicuotas(df_san_juan_22,"alicuota",0.3)

#Agregamos tratamientos especiales (según variable nota)

lista_0<-c("1","3","9","10","24","25","26","30","32","35","36")
lista_2_3<-c("6")
lista_2<-c("7")
lista_1_75<-c("12")
lista_3<-c("16","19","28")
lista_5<-c("2","10","11","40")

df_san_juan_22<-df_san_juan_22%>%
  mutate(alicuota_1=ifelse(nota %in% lista_0, 0, 
                           ifelse(nota %in% lista_5, 5, 
                                  ifelse(nota %in% lista_3, 3, 
                                         ifelse(nota=="6", 2.3,
                                                ifelse(nota=="7", 2, 
                                                       ifelse(nota=="12", 1.75, 
                                                              ifelse(nota=="13",0.45,
                                                                     ifelse(nota=="23",1.5,
                                                                            ifelse(nota=="31",12.5,
                                                                                   alicuota)
                                                                            )
                                                                     )
                                                              )
                                                       )
                                                )
                                         )
                                  )
                           ), 
         alicuota_2=ifelse(nota=="10", 5, 
                           alicuota)
       )                          
temp<-min_max(df_san_juan_22,"alicuota","codigo_NAES")

names(temp)<-c("codigo_NAES","min_ali","max_ali") #No logramos poner nombres correctos en la función, así que los corregimos aquí afuera

#Agregamos sobrealícuota de 20% por Lote Hogar
df_san_juan_NAES_22<-lista_NAES%>%
  left_join(temp)%>%
  mutate(min_ali=min_ali*1.2,
         max_ali=max_ali*1.2)

faltantes<-df_san_juan_NAES_22%>%
  subset(is.na(max_ali))
head(faltantes)


drive_trash("San_Juan_NAES_22")
gs4_create(name="San_Juan_NAES_22",sheets=df_san_juan_NAES_22)
drive_mv(file="San_Juan_NAES_22",path=id_carpeta)

rm(temp,id_san_juan,faltantes)

######## Cuadro NAES IIBB, San Luis------

id_san_luis<-drive_get("san_luis_22_alicuota")
df_san_luis_22<-read_sheet(ss=id_san_luis)
names(df_san_luis_22)<-c("cuadro","codigo_NAES","descripcion","alicuota_1","alicuota_2","alicuota_3","fuente")

df_san_luis_22<-df_san_luis_22%>%
  mutate(alicuota_1=gsub("[^0-9.-]", NA, alicuota_1),
         alicuota_2=gsub("[^0-9.-]", NA, alicuota_2),
         alicuota_3=gsub("[^0-9.-]", NA, alicuota_3),
         codigo_NAES=gsub("[^0-9.-]", NA, codigo_NAES),
         alicuota_1=ifelse(codigo_NAES=="477469", 4.20, 
                           alicuota_1),
         alicuota_2=ifelse(codigo_NAES=="477469", 3.50, 
                           alicuota_2),
         alicuota_3=ifelse(codigo_NAES=="477469", 2.00, 
                           alicuota_3),
         
         alicuota_2=ifelse(is.na(codigo_NAES), descripcion,  #CUando la descripción estaba en dos líneas, la alícuota 1 terminó en descripción
                           alicuota_2),
         group_id=row_number(), 
         group_id=ifelse(is.na(codigo_NAES) | codigo_NAES=="", group_id-1,
                         group_id)
         )%>%
  group_by(group_id)%>%
  fill(alicuota_1)%>%
  fill(alicuota_1,.direction="up")%>%  #Hay que expandir la alícuota cuando la descripción estaba en dos líneas
  
  fill(alicuota_2)%>%
  fill(alicuota_2,.direction="up")%>%  #Hay que expandir la alícuota cuando la descripción estaba en dos líneas
  
  fill(alicuota_3)%>%
  fill(alicuota_3,.direction="up")%>%  #Hay que expandir la alícuota cuando la descripción estaba en dos líneas
  ungroup()%>%
  mutate(borrar=ifelse(is.na(alicuota_1) & is.na(alicuota_2) & is.na(alicuota_3), 1, 
                       0)
         )%>%
  subset(borrar==0)


df_san_luis_22<-formateo_alicuotas(df_san_luis_22,"alicuota",0.3)
temp<-min_max(df_san_luis_22,"alicuota","codigo_NAES")
names(temp)<-c("codigo_NAES","min_ali","max_ali") #No logramos poner nombres correctos en la función, así que los corregimos aquí afuera

df_san_luis_NAES_22<-lista_NAES%>%
  left_join(temp)

faltantes<-df_san_luis_NAES_22%>%
  subset(is.na(max_ali))
head(faltantes)

rm(temp,id_san_luis,list=ls(pattern="faltantes"))


drive_trash("San_Luis_NAES_22")
gs4_create(name="San_Luis_NAES_22",sheets=df_san_luis_NAES_22)
drive_mv(file="San_Luis_NAES_22",path=id_carpeta)



######## Cuadro NAES IIBB, Santa Cruz------

id_santa_cruz<-drive_get("santa_cruz_alícuota22")
df_santa_cruz_22<-read_sheet(ss=id_santa_cruz)
names(df_santa_cruz_22)<-c("cuadro","codigo_NAES","descripcion","alicuota","fuente")

df_santa_cruz_22<-df_santa_cruz_22%>%
  mutate(cod_num=as.integer(codigo_NAES), 
         codigo_NAES=ifelse(cod_num<100000, paste0("0",cod_num), #Agregamos un 0 a la izquierda del código NAES
                   codigo_NAES)
        )

df_santa_cruz_22<-formateo_alicuotas(df_santa_cruz_22,"alicuota",0.3)
temp<-min_max(df_santa_cruz_22,"alicuota","codigo_NAES")
names(temp)<-c("codigo_NAES","min_ali","max_ali") #No logramos poner nombres correctos en la función, así que los corregimos aquí afuera


df_santa_cruz_NAES_22<-lista_NAES%>%
  left_join(temp)

faltantes<-df_santa_cruz_NAES_22%>%
  subset(is.na(max_ali))%>%
  mutate(codigo_corto=substr(start=1,stop=5,codigo_NAES)) #Hay códigos NAES más generales para Santa Cruz, con sólo 5 dígitos


temp_faltantes<-temp%>%
  mutate(codigo_corto=substr(start=1,stop=5,codigo_NAES))%>%
  select(-c(codigo_NAES))%>%
  group_by(codigo_corto)%>%
  summarise(min_ali=min(min_ali), 
            max_ali=max(max_ali))%>%
  ungroup()


faltantes<-faltantes%>%
  select(-c(min_ali,max_ali))%>%
  left_join(temp_faltantes)%>%
  distinct()%>%
  select(-c(codigo_corto))

df_santa_cruz_NAES_22<-df_santa_cruz_NAES_22%>%
  subset(!is.na(max_ali))%>%
  rbind(faltantes)%>%
  mutate(min_ali=ifelse(codigo_NAES=="451111" | codigo_NAES=="451112", 3, 
                        min_ali), 
         max_ali=ifelse(codigo_NAES=="451111" | codigo_NAES=="451112", 3, 
                        max_ali)
         )%>%
  arrange(codigo_NAES)

faltantes<-df_santa_cruz_NAES_22%>%
  subset(is.na(max_ali))
head(faltantes)

rm(id_santa_cruz,list=ls(pattern="faltantes"),temp)

drive_trash("Santa_Cruz_NAES_22")
gs4_create(name="Santa_Cruz_NAES_22",sheets=df_santa_cruz_NAES_22)
drive_mv(file="Santa_Cruz_NAES_22",path=id_carpeta)





#### Cuadro NAES IIBB. Santiago del Estero ------------
##Para Santiago del Estero, obtenemos un pdf de la Dirección General de Rentas, con código CUACM. 
id_santiago_del_estero<-drive_get("Santiago_del_Estero_2022")
df_santiago_del_estero_22<-read_sheet(ss=id_santiago_del_estero)
#Por Art. 2 de la Ley 7.339, la venta en comisión y/o directa de automotores nuevos está impuesta al 10%. Se corrige la alícuota en la
#tabla correspondiente
#Para las demás posiciones, nos fiamos a la fuente informada por ERREPAR, sin entrar en más detalles.
df_santiago_del_estero_22<-df_santiago_del_estero_22%>%
  mutate(ALICUOTA=ifelse(CODIGO %in% c("501111","501112","501191","501192","501295"), 10, #Venta de automotores nuevos
                         ALICUOTA), 
         fuente=ifelse(CODIGO %in% c("501111","501112","501191","501192","501295"), "Art. 2 Ley 7.339", 
                       "Leyes 6.793, 7.051, 7.160, 7,241, 7,249 y 7.271, siguiendo ERREPAR") 
  )
rm(id_santiago_del_estero)




######## Cuadro NAES IIBB, Tierra del Fuego------


id_tdf<-drive_get("tdf_22_alicuota")
df_tdf_22<-read_sheet(ss=id_tdf)
names(df_tdf_22)<-c("cuadro","codigo_NAES","descripcion","incluye","excluye","alicuota")
#Existe una sobrealícuota de 4% sobre algunas actividades financieras, destinada al Fondo de Financiamiento para el Sistema Previsional, desde el 1/2/2016 
lista_sistema_previsional<-c(641100,641910,641920, 641930, 641941, 641942, 641943, 642000, 643001, 643009, 649100, 649210, 649220, 649290, 649910, 649991, 649999, 651110, 
                             651120, 651130, 651210, 651220, 651310, 652000, 653000, 661111, 661121, 661131, 661910, 661920, 661930, 661991, 661992, 661999, 662010, 662020, 
                             662090,663000)


df_tdf_22<-df_tdf_22%>%
  mutate(alicuota_26_bis=ifelse(codigo_NAES=="331290", "3,5%", #Incluimos algunas alícuotas especiales detalladas en el art. 26 bis
                                ifelse(codigo_NAES=="472200", "3%", 
                                       ifelse(codigo_NAES=="473001", "1,5%", 
                                              ifelse(codigo_NAES=="473002", "3,5%", 
                                                     ifelse(codigo_NAES=="477440", "3%", 
                                                            ifelse(codigo_NAES=="522099", "3,5%", 
                                                                   ifelse(codigo_NAES=="920009", "15%", 
                                                                          NA))
                                                            )
                                                     )
                                              )
                                       )
                                ),
         cod_num=as.integer(codigo_NAES), 
         codigo_NAES=ifelse(cod_num<100000, paste0("0",cod_num), 
                            codigo_NAES), 
         #Casi todas las actividades tienen una sobrealícuota para el Fondo de Financiamiento de Servicios Sociales, siguiendo la cateogrización siguiente:
         alicuota_serv_soc=ifelse((cod_num>=11111 & cod_num<=24020) | cod_num==89200 | (cod_num>=131110 & cod_num<=143020) | (cod_num>=151100 & cod_num<=152031)
                                  | (cod_num>=201110 & cod_num<=222090) | (cod_num>=261000 & cod_num<=264000) | (cod_num>=267001 & cod_num<=268000) | (cod_num>=275010 & cod_num<=279000)
                                  | cod_num==281700 | cod_num==293090 | cod_num==352010 | cod_num==352021 | cod_num==352022 | cod_num==492130,"0%",
                                  ifelse(cod_num==493110 | cod_num==493120 | cod_num==493200, "1%", 
                                         ifelse((cod_num>=101011 & cod_num<=108000) | cod_num==110100 | (cod_num>=110411 & cod_num<=110492) | (cod_num>=152040 & cod_num<=192002) 
                                                | cod_num==201140 | cod_num==201210 | (cod_num>=231010 & cod_num<=259999) | (cod_num>=265101 & cod_num<=266090) | (cod_num>=271010 & cod_num<=274000)
                                                | (cod_num>=281100 & cod_num<=281600) | (cod_num>=281900 & cod_num<=293011) | (cod_num>=301100 & cod_num<=329099) | (cod_num>=331210 & cod_num<=331290)
                                                | cod_num==331301 | cod_num==331400 | cod_num==382010 | cod_num==382020 | (cod_num>=581100 & cod_num<=592000) | cod_num==951200, "1,25%",
                                                ifelse(cod_num==31110 | cod_num==31120 | cod_num==31130 | cod_num==31200 | cod_num==31300 | cod_num==32000 | cod_num==51000 | cod_num==52000 
                                                       | (cod_num>=71000& cod_num<=89120) | cod_num==89300 | cod_num==89900, "0,5%", 
                                                       "1,5%")
                                                )
                                         )
                                ), 
         alicuota_sist_prev=ifelse(cod_num %in% lista_sistema_previsional, "4%", "0%")
           
         )
df_tdf_22<-formateo_alicuotas(df_tdf_22,"alicuota",0.2)
df_tdf_22<-df_tdf_22%>%
  mutate(alicuota_1=alicuota + alicuota_serv_soc + alicuota_sist_prev, 
         alicuota_2=alicuota_26_bis + alicuota_serv_soc + alicuota_sist_prev)%>%
  select(-c(alicuota_serv_soc,alicuota_sist_prev,alicuota,alicuota_26_bis))

temp<-min_max(df_tdf_22,"alicuota","codigo_NAES")
names(temp)<-c("codigo_NAES","min_ali","max_ali") #No logramos poner nombres correctos en la función, así que los corregimos aquí afuera

df_tdf_NAES_22<-lista_NAES%>%
  left_join(temp)%>%
  mutate(min_ali=ifelse(codigo_NAES=="681010", 4.5, #Faltaba en ERREPAR esta actividad, le ponemos la imposición de actividades vecinas
                        min_ali), 
         max_ali=ifelse(codigo_NAES=="681010", 4.5, 
                        max_ali)
        )

faltantes<-df_tdf_NAES_22%>%
  subset(is.na(max_ali))
head(faltantes)

rm(id_tdf,list=ls(pattern="faltantes"),temp)

drive_trash("TDF_NAES_22")
gs4_create(name="TDF_NAES_22",sheets=df_tdf_NAES_22)
drive_mv(file="TDF_NAES_22",path=id_carpeta)
