
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

gs4_auth() #Conección a la cuenta google

id_carpeta<-drive_get("Relevamiento_alicuotas")
####Casos particulares ------------
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

##### Exportamos los cuadros sacados de ERREPAR, con códigos NAES ------

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



######## Cuadro NAES IIBB, CABA------
id_CABA<-drive_get("CABA_alícuota22")
df_CABA_22<-read_sheet(ss=id_CABA) #Importamos cuadro modificado, con alícuota agregada
names(df_CABA_22)<-c("cuadro","codigo_NAES","descripcion","alicuota_1","alicuota_2","alicuota_3","fuente")

df_CABA_22<-df_CABA_22%>%
  mutate(across(where(is.list),~ifelse(.x=="NULL", NA, #Ponemos como valores faltantes las alícuotas que tienen el valor "NULL"
                                                .x)), 
         across(where(is.list),~as.character(.x)),#Se importaron las alícuotas como listas, no caracteres; lo corregimos aquí
         across(everything(),~gsub("%","",.x)), #Sacamos los % de las alícuotas, así las podremos pasar a numérico
         across(starts_with("alicuota"),~gsub(",",".",.x)), #Reemplazamos las comas por puntos en las alícuotas, así las podremos pasar a numérico
         es_numerica=ifelse(substr(start=1,stop=1,codigo_NAES) %in% c("0","1","2","3","4","5","6","7","8","9"), 1,
                            0) #Quitamos las observaciones que no corresponden a un código NAES definido
         )%>%
  subset(es_numerica==1)%>%
  select(-c(es_numerica))%>%
  mutate(across(starts_with("alicuota"),~as.double(.x)), #Pasamos las alícuotas a numérico
         across(starts_with("alicuota"),~ifelse(.x<0.2, .x*100, #Se importaron algunas alícuotas, en vez de 10%, como 0,1. Se corrige aquí
                                                .x)
                )
         )%>%
  select(-c(cuadro))%>%# No es más necesaria la información del cuadro en que estaba el nomenclador
  distinct()#Hay algunos nomencladores repetidos por error de ERREPAR; los sacamos

#Para la tabla comparativa, vamos a tomar siempre la alícuota más alta posible para cada actividad (en general grandes contribuyentes).
#Se puede hacer lo mismo con la más baja posible para cada actividad.

min_max<-function(input,variables,id_variable,min_name,max_name){ #Valores mínimos y máximos de una clase de variables, siguiendo un id
  var_ali<-as_tibble(input)%>%
    select(starts_with(variables))
  
  lista_alicuotas<-names(var_ali) #Creamos una lista con las variables que empiecen con "alicuota"
  
  output<-input%>%
    mutate(minimum=invoke(pmax,c(across(all_of(lista_alicuotas)),na.rm=TRUE)), #Valor máximo entre las variables que empiecen con "alicuota"
           maximum=invoke(pmin,c(across(all_of(lista_alicuotas)),na.rm=TRUE))#Valor máximo entre las variables que empiecen con "alicuota"
          )%>%
    group_by(get(id_variable))%>%
    summarise(min_name=min(minimum),
              max_name=max(maximum)
              )%>%
    ungroup()
}

temp<-min_max(df_CABA_22,"alicuota","codigo_NAES",min_ali,max_ali)
names(temp)<-c("codigo_NAES","min_ali","max_ali")

df_CABA_NAES_22<-lista_NAES%>%
  left_join(temp)
head(df_CABA_NAES_22)

faltantes<-df_CABA_NAES_22%>%
  subset(is.na(max_ali))
head(faltantes)

rm(faltantes,temp,id_CABA)

gs4_create(name="CABA_NAES_22",sheets=df_CABA_NAES_22)
drive_mv(file="CABA_NAES_22",path=id_carpeta)