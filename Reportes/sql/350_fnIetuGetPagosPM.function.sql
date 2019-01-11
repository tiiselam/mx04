-------------------------------------------------------------------------------------------------
IF OBJECT_ID ('dbo.fnIetuGetPagosPM') IS NOT NULL
   DROP FUNCTION dbo.fnIetuGetPagosPM
GO

create function dbo.fnIetuGetPagosPM(@VCHRNMBR varchar(21), @DOCTYPE smallint)
returns table
as
--Propósito. Obtiene datos del pago original: 
--			pago simultáneo en factura, misceláneos, pagos mcp, pagos manuales, pagos anulados, cheques computarizados
--Requisitos. 
--09/01/13 jcf Creación 
--
return
( 
	--Documentos PM: factura, misceláneos, pagos, anulación de facturas, cheques computarizados
	select pt.txrgnnum, pt.USERDEF1, pt.doctype, pt.vchrnmbr,
		'' poprctnm, 
		case when pt.ttlpymts <> 0 then		--pago simultáneo en la factura
			ie.voided_apfr					--pago anulado?
		else
			 pt.voided 
		end voided,
		isnull(ie.aplica_IETU, 0) aplica_IETU, isnull(ie.prchamntProporcional, 0) prchamntProporcional, 0 slsamntProporcional
	from vwPmTransaccionesTodas pt			--[doctype, vchrnmbr]
		outer apply dbo.fnAplicaIETU(pt.VCHRNMBR, pt.DOCTYPE, pt.ttlpymts) ie
	where --@SOURCEDOC in ('PMTRX', 'PMPAY', 'PMVVR', 'PMVPY', 'PMCHK')
	 pt.VCHRNMBR = @VCHRNMBR
	and pt.DOCTYPE = @DOCTYPE
)
go

IF (@@Error = 0) PRINT 'Creación exitosa de la función: fnIetuGetPagosPM()'
ELSE PRINT 'Error en la creación de la función: fnIetuGetPagosPM()'
GO
