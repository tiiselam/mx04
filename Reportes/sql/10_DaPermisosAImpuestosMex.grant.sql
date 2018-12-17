--México 
--Impuestos IETU, ISR
--Propósito. Rol que da accesos a objetos de IETU
--Requisitos. Ejecutar en la compañía.
--24/05/11 JCF Creación
--
-----------------------------------------------------------------------------------
--use [COMPAÑIA]

IF DATABASE_PRINCIPAL_ID('rol_ietu') IS NULL
	create role rol_ietu;

--Objetos que usa reporte base del ietu
grant select on dbo.vwGlTransaccionesIetu to rol_ietu, dyngrp;

