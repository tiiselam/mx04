IF OBJECT_ID ('dbo.vwGlTransaccionesIetu') IS NOT NULL
   DROP view vwGlTransaccionesIetu
GO

create view dbo.vwGlTransaccionesIetu as  
--Propósito. Asientos contables para IETU
--Requisitos. Debe estar instalada la vista [vwFINAsientosTAH]
--				También usa las funciones DYN_FUNC_Series_GL_Trx y DYN_FUNC_Account_Category_Number de los reportes SSRS de GP
--26/07/12 jcf Creación 
--26/11/12 jcf Agrega actnumbr_5, 6
--08/01/13 jcf Corrige rmBaseDelIva y pmBaseDelIva. Sólo calcula cuando es cuenta de balance.
--18/01/13 jcf Agrega datos de control de reclasificación de impuestos en todas las consultas
--
select T1.jrnentry as 'Entrada de diario',	
	dbo.DYN_FUNC_Series_GL_Trx(
		case when isnull(do.origenDoc, 'na') = 'RC' then 3	--reversión de cobro
			when isnull(do.origenDoc, 'na') = 'RP' then 4	--reversión de pago
			else T1.series
		end
		) 'Serie',	
	--dbo.DYN_FUNC_Series_GL_Trx(T1.series) N'Serie',	
	T1.SOURCDOC [Documento origen],
	year(T1.trxdate) N'año',	MONTH(T1.trxdate) mes,	T1.trxdate [Fecha trans.],	isnull(T1.ACTNUMST, '') as N'Número de cuenta',
	isnull(T1.actdescr, '') as N'Descripción cuenta',
	T1.debitamt as N'Monto débito',
	T1.crdtamnt as N'Monto crédito',
	T1.debitamt - T1.crdtamnt montoNeto,
	'' as N'Año cerrado',	isnull(T1.curncyid, '') as 'Id. de moneda',	isnull(T1.dscriptn, '') as N'Descripción',
	0 [Fecha del documento],	isnull(T1.origen, '') as 'Estado del documento',
	T1.xchgrate as 'Tasa de cambio',
--	isnull(T1.ACTNUMBR_3, '') as 'Segmento cuenta principal',
	'' as N'Año abierto',	T1.ORTRXTYP [Tipo trans. original],	isnull(T1.ORCTRNUM, '') as N'Número de control original',
	T1.ORCRDAMT as N'Monto crédito original',
	T1.ORDBTAMT as N'Monto débito original',
	isnull(T1.ORDOCNUM, '') as N'Núm. documento original',
	isnull(T1.ORMSTRID, '') as 'Id. maestro original',
	isnull(T1.ORMSTRNM, '') as 'Nombre maestro original',
	T1.periodid as N'Id. de período',
	isnull(T1.refrence, '') as 'Referencia',
	isnull(T1.ACTNUMBR_1, '') ACTNUMBR_1,
	isnull(T1.ACTNUMBR_2, '') ACTNUMBR_2,
	isnull(T1.ACTNUMBR_3, '') ACTNUMBR_3,
	isnull(T1.ACTNUMBR_4, '') ACTNUMBR_4,
	isnull(T1.ACTNUMBR_4, '') ACTNUMBR_5,
	isnull(T1.ACTNUMBR_4, '') ACTNUMBR_6,
	isnull(T1.ACCTTYPE, 0) as 'Tipo de cuenta',
	isnull(T1.actdescr, '') as N'Descripción cuenta de maestro de cuentas',
	isnull(T1.PSTNGTYP, 0) as N'Tipo de contabilización',
	isnull(dbo.DYN_FUNC_Account_Category_Number(T1.ACCATNUM), '') as N'Número categoría cuenta',
	isnull(do.txrgnnum, '') RFC, isnull(do.USERDEF1, '') CURP, 
	isnull(do.doctype, 0) doctype, isnull(do.vchrnmbr, '') vchrnmbr, isnull(do.poprctnm, '') poprctnm, isnull(do.aplica_IETU, 0) aplica_IETU, 
	case when T1.pstngtyp = 1 then 0 else isnull(do.prchamntProporcional,0) end pmBaseDelIva,	
	case when T1.pstngtyp = 1 then 0 else isnull(do.slsamntProporcional, 0) end rmBaseDelIva,	
	ISNULL(do.voided, 0) 'Anulado', 
    isnull(do.processType, 0) 'Tipo proceso', 
    case when isnull(do.processYear, 0) = 0 then year(T1.trxdate) else do.processYear end N'Año proceso', 
    case when isnull(do.processMonth, 0) = 0 then MONTH(T1.trxdate) else do.processMonth end 'Mes proceso', 
    isnull(do.processDate, 0) 'Fecha proceso', isnull(do.taxStatus, -1) 'Estado del impuesto'
from dbo.vwFINAsientosTAH T1 
outer apply dbo.fnGetDocumentoOriginal(T1.ORCTRNUM, T1.ORTRXTYP, T1.SOURCDOC, T1.jrnentry, T1.series) do

go

IF (@@Error = 0) PRINT 'Creación exitosa de: vwGlTransaccionesIetu'
ELSE PRINT 'Error en la creación de: vwGlTransaccionesIetu'
GO

---------------------------------------------------------------------------------------------------
--GETTY: ACTNUMBR_3 [Segmento cuenta principal], ACTNUMBR_1 Brand, ACTNUMBR_2 [Compañía], ACTNUMBR_3 Cuenta, ACTNUMBR_4,
--MACLEAN: ACTNUMBR_2 [Segmento cuenta principal], ACTNUMBR_1 [Región], ACTNUMBR_2 Main, ACTNUMBR_3 Employee, ACTNUMBR_4 [Expense Type],
--GTP: ACTNUMBR_1 [Segmento cuenta principal], ACTNUMBR_1 Main, ACTNUMBR_2 Country, ACTNUMBR_3 [State/Region], ACTNUMBR_4 [Site], ACTNUMBR_5 Department, ACTNUMBR_6 Entity,

--Para el reporte excel
--select [Entrada de diario],[Serie],[Documento origen],[año], mes, [Fecha trans.],[Número de cuenta],[Descripción cuenta],[Monto débito],[Monto crédito],
-- montoNeto, [Id. de moneda] ,[Descripción],[Fecha del documento],[Estado del documento],[Tasa de cambio],
-- [Año abierto],[Tipo trans. original],[Número de control original],[Monto crédito original],[Monto débito original],
-- [Núm. documento original],[Id. maestro original],[Nombre maestro original],[Id. de período],[Referencia],
--ACTNUMBR_3 [Segmento cuenta principal], ACTNUMBR_1 Brand, ACTNUMBR_2 [Compañía], ACTNUMBR_3 Cuenta, ACTNUMBR_4,
-- [Tipo de cuenta],[Descripción cuenta de maestro de cuentas],[Tipo de contabilización],[Número categoría cuenta],
-- [RFC], CURP, [doctype],[vchrnmbr],[poprctnm],[aplica_IETU],pmBaseDelIva, rmBaseDelIva, Anulado,
-- [Tipo proceso], [Año proceso], [Mes proceso], [Fecha proceso], [Estado del impuesto]
-- from dbo.vwGlTransaccionesIetu
--where [Estado del documento] = 'Abrir'
--and [Estado del impuesto] >= 0
----[Número de control original] = '0004340' 
--[Año]= 2012
--and mes = 10
----and serie = 'Ventas'
--and [Número de control original] = 'RECCOB00003997' 
----and [Id. maestro original] like '9999999%'
--and aplica_IETU = 1

--and N'Entrada de diario' = 16895
--order by 1

