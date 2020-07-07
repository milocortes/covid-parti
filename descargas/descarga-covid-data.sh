#!/bin/bash

# Generamos un archivo de texto con las ligas de los .zip de los datos
cat covid_historico.html | grep http://187.191.75.115/gobmx/salud/datos_abiertos/historicos/  |  grep -Po '(?<=(href=")).*(?=")' > covid_links.txt
# Descargamos los .zip
wget -i  covid_links.txt

# Descomprimimos los .zip
unzip \*.zip

# Removemos los .zip
rm *.zip

# Comprimimos los .csv en un .zip
zip  data-covid.zip *.csv

# Generamos un archivo de texto con los nombres de los csv
ls *.csv > lista_datos.txt

# Algunos csv no están en utf-8, de manera que usamos iconv para cambiarlos a utf-8

for word in $(cat lista_datos.txt);
do
echo $word;

FROM_ENCODING=$(file -i $word |  grep -Po '(?<=(charset=)).*(?=)');
TO_ENCODING="UTF-8";

echo $FROM_ENCODING

iconv -c -f $FROM_ENCODING -t $TO_ENCODING < $word > "utf-8-${word}"

mv "utf-8-${word}" $word

done

# Creamos el directorio data-covid en tmp
mkdir /tmp/data-covid

mv *.csv /tmp/data-covid

# Corremos el .sql para crear la tabla tb_covid. Previamente se debió haber creado la base de datos dbcovid

#psql -U postgres -d dbcovid -a -f covid-particip-estatal.sql

# Copiamos los csv en la tabla tb_covid
# Importamos los archivos
for i in in $(cat lista_datos.txt);
    do
        echo "Cargado a la tabla el archivo : ${i}"
        psql -U postgres -d dbcovid -c  "COPY tb_covid(fecha_actualizacion,id_registro,origen,sector,entidad_um,sexo,entidad_nac,entidad_res,municipio_res,tipo_paciente,fecha_ingreso,fecha_sintomas,fecha_def,intubado,neumonia,edad,nacionalidad,embarazo,habla_lengua_indig,diabetes,epoc,asma,inmusupr,hipertension,otra_com,cardiovascular,obesidad,renal_cronica,tabaquismo,otro_caso,resultado,migrante,pais_nacionalidad,pais_origen,uci
       ) from PROGRAM 'cat /tmp/data-covid/${i}'  DELIMITERS ','   WITH CSV HEADER NULL 'NA'"
    done
