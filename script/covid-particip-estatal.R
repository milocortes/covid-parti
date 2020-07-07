### Limpiamos el ambiente de trabajo
rm(list = ls())

### Cargamos las librerías
library(RPostgreSQL)
library(dplyr)

#### Librerías para el gif
library(animation)
library(lubridate)
library(XML)
library(mosaic)

#### Para la gráfica
library("ggpubr")

### Cargamos las fechas de registo de casos
archivos<-read.table("../descargas/lista_datos.txt",col.names = "archivo")

### Cargamos el diccionario de entidades
dic_ent<-read.csv("../input/dic_entidades.csv")

### Obtenemos las fechas de los archivos
anio<-paste(substring(archivos$archivo,1,2),"20",sep = "")
mes<-substring(archivos$archivo,3,4)
dia<-substring(archivos$archivo,5,6)

fechas<-paste(anio,"-",mes,"-",dia,sep="")

# Creamos la conexión a la base de datos
# Guardamos la clave 
pw <- {"clave-postgres"}

# Cargamos el driver de PostgreSQL 
drv <- dbDriver("PostgreSQL")
# Creamos una conexión a la base de datos de postgres 
con <- dbConnect(drv, dbname = "dbcovid",
                 host = "localhost", port = 5432,
                 user = "usuario-postgres", password = pw)

# removemos la clave
rm(pw) 

# Checamos si existe la tabla tb_covid
dbExistsTable(con, "tb_covid")

# Hacemos el gif realizando consultas de cada día en la tabla tb_covid
saveGIF({
for (i in c(9:length(fechas))) {
  
  # Imprimimos la fecha t para la que estamos realizando la figura
  print(fechas[i])
  
  # Generamos la consulta para la fecha t
  consulta_t<-paste("SELECT fecha_actualizacion,id_registro,entidad_res,resultado from tb_covid WHERE fecha_actualizacion='",fechas[i],"' AND resultado=1",sep = "")
  
  # Generamos la consulta para la fecha t-1
  consulta_t_1<-paste("SELECT fecha_actualizacion,id_registro,entidad_res,resultado from tb_covid WHERE fecha_actualizacion='",fechas[i-1],"' AND resultado=1",sep = "")
  
  # Generamos los data frames de estas consultas
  consulta_df_t<-dbGetQuery(con, consulta_t)
  consulta_df_t_1<-dbGetQuery(con, consulta_t_1)

  # De todos excluimos los casos positivos en t-1 de los casos positivos en t
  covid_analisis<-consulta_df_t[(!consulta_df_t$id_registro %in% consulta_df_t_1$id_registro),]
  
  # Obtenemos los conteos de casos diarios en t por entidad federativa
  casos_entidad<- covid_analisis %>% group_by(entidad_res) %>% tally()
  
  # Hacemos el cast a numérico de la clave de la entidad
  casos_entidad$entidad_res<-as.numeric(casos_entidad$entidad_res)

  # Hacemos un merge con nuestro diccionario de entidades
  casos_entidad<-merge(casos_entidad,dic_ent,by="entidad_res", all.y = TRUE)
  
  # Los NA los convertimos en 0
  casos_entidad[is.na(casos_entidad)]<-0
  
  # Obtenemos el porcentaje de participación por entidad federativa en el total nacional de casos positivos
  casos_entidad$porcentaje<-(casos_entidad$n/sum(casos_entidad$n))*100
  
  # Modificamos el nombre de las columnas
  colnames(casos_entidad)<-c("entidad_res","n","entidad","grupo","porcentaje")
  
  # Generamos la figura
  p<-ggdotchart(casos_entidad, x = "entidad", y = "porcentaje",
                group = "grupo",                                
                color = "grupo",                                
                palette = c("#E7B800", "#00AFBB"), 
                sorting = "none",                       
                add.params = list(color = "lightgray", size = 2), 
                dot.size = 6,
                add = "segments",
                label = round(casos_entidad$porcentaje,2),
                font.label = list(color = "black", size = 9, 
                                  vjust = 0.5),               
                ggtheme = theme_pubr())+ geom_hline(yintercept = 0, linetype = 2, color = "lightgray")
  
  print(p+labs( 
    title= "Participación en el total diario de casos positivos por entidad federativa", 
    subtitle=fechas[i],
    caption = "Fuente:Datos Abiertos-Dirección General de Epidemiología. Liga: https://www.gob.mx/salud/documentos/datos-abiertos-bases-historicas-direccion-general-de-epidemiologia"))
}
  },
  interval=.2, ani.width = 800, ani.height = 400)
