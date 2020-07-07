/*
 Para abrir sesión de postgresql
 sudo -u postgres psql

 Eliminamos la bd dbcovid

 DROP DATABASE dbcovid;

 Creamos nuevamente la bd dbcovid

 CREATE DATABSE dbcovid;

 Incorporamos la extensión PostGIS

 CREATE EXTENSION  postgis

 Para ejecutar el script
 psql -U postgres -d dbcovid -a -f covid-particip-estatal.sql
*/

/*
  ################################################
  Creamos la tabla de los datos públicos de covid
  ################################################
*/


CREATE TABLE tb_covid (
  fecha_actualizacion VARCHAR(20),
  id_registro VARCHAR(20) NOT NULL,
  origen INTEGER,
  sector INTEGER,
  entidad_um VARCHAR(20),
  sexo INTEGER,
  entidad_nac VARCHAR(20),
  entidad_res VARCHAR(20),
  municipio_res  VARCHAR(20),
 tipo_paciente  INTEGER,
  fecha_ingreso VARCHAR(20),
  fecha_sintomas  VARCHAR(20),
  fecha_def   VARCHAR(20),
  intubado  INTEGER,
  neumonia  INTEGER,
  edad    INTEGER,
  nacionalidad  INTEGER,
  embarazo  INTEGER,
  habla_lengua_indig  INTEGER,
  diabetes  INTEGER,
  epoc   INTEGER,
  asma  INTEGER,
  inmusupr   INTEGER,
  hipertension  INTEGER,
  otra_com    INTEGER,
  cardiovascular   INTEGER,
  obesidad   INTEGER,
  renal_cronica   INTEGER,
  tabaquismo  INTEGER,
  otro_caso    INTEGER,
  resultado  INTEGER,
  migrante    INTEGER,
  pais_nacionalidad VARCHAR(400),
  pais_origen VARCHAR(400),
  uci   INTEGER
  );
