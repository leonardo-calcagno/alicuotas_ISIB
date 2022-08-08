
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

df_CABA_22<-formateo_alicuotas(df_CABA_22,"alicuota",0.2)
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
         
rm(faltantes,temp,temp_faltantes,id_CABA)

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
