-------------------------------------------------------------------------------------------------
IF OBJECT_ID ('dbo.fnGetDocumentoOriginal') IS NOT NULL
   DROP FUNCTION dbo.fnGetDocumentoOriginal
GO

create function dbo.fnGetDocumentoOriginal(@VCHRNMBR varchar(21), @DOCTYPE smallint, @SOURCEDOC varchar(11), @JRNENTRY int, @series smallint)
returns table
as
--Propósito. Obtiene los comprobantes originales de facturas, pagos y cobros
--Requisitos. 
--25/07/12 jcf Creación 
--23/08/12 jcf Filtra pagos RM que aplican sólo a facturas.
--27/11/12 jcf El campo slsamntProporcional no es necesario para facturas de venta SJ. 
--			El campo aplica_IETU de las facturas de venta debe ser cero para excluirlas del reporte
--09/01/13 jcf Corrige el cálculo de la base imponible en la sección Pagos RM y de las facturas SOP pagadas simultáneamente.
--				Corrige el campo voided de la sección Documentos PM. 
--				Reorganiza llamadas a funciones
--18/01/13 jcf Agrega datos de control de reclasificación de impuestos en todas las consultas
--23/01/13 jcf Agrega parámetro @series 
--
return
( 
	--Documentos PM: factura, misceláneos, pagos, anulación de facturas, cheques computarizados
	select cast('P' as varchar(2)) origenDoc, pt.txrgnnum, pt.USERDEF1, pt.doctype, pt.vchrnmbr,
		pt.poprctnm, pt.voided, pt.aplica_IETU, pt.prchamntProporcional, pt.slsamntProporcional,
		2 processType, isnull(rc.YEAR1, 0) processYear, isnull(rc.MONTHINTERVAL, 0) processMonth, isnull(rc.TRXDATE, 0) processDate, isnull(rc.ACA_RID_Tax_Status, 0) taxStatus
	from dbo.fnIetuGetPagosPM(@VCHRNMBR, @DOCTYPE ) pt
		left join ACA_RID10000 rc						--control de reclasificiaciones de impuestos
		on rc.TXDTLTYP = 2								--compras
		and rc.DOCTYPE = pt.doctype
		and rc.VCHRNMBR = pt.vchrnmbr
		and rc.ACA_RID_Last = 1
	where @SOURCEDOC in ('PMTRX', 'PMPAY', 'PMVVR', 'PMVPY', 'PMCHK')

	--union all

	--Recepciones y facturas POP
	--select isnull(pt.txrgnnum, '') txrgnnum, isnull(pt.USERDEF1, '') USERDEF1, isnull(pt.doctype, 0) doctype, isnull(pt.vchrnmbr, '') vchrnmbr, 
	--	pr.poprctnm, isnull(pt.voided, 0) voided, 
	--	isnull(ie.aplica_IETU, 0) aplica_IETU, isnull(ie.prchamntProporcional, 0), 0
	--from vwPopRecepcionesHdr pr				--facturas pop
	--left join vwPmTransaccionesTodas pt		--[doctype, vchrnmbr]
	--	on pr.VCHRNMBR = pt.VCHRNMBR
	--	and pt.DOCTYPE = 1					--invoice
	--outer apply dbo.fnAplicaIETU(pr.VCHRNMBR, 1, 0) ie
	--where @SOURCEDOC = 'RECVG'
	--and pr.POPRCTNM = @VCHRNMBR

	union all
	
	--cobros RM
	select cast('C' as varchar(2)) origenDoc, rm.txrgnnum, rm.USERDEF1, rm.RMDTYPAL, rm.DOCNUMBR,
		'' poprctnm, rm.VOIDstts, rm.aplica_IETU, rm.prchamntProporcional, rm.slsamntProporcional,
		1 processType, isnull(rc.YEAR1, 0) processYear, isnull(rc.MONTHINTERVAL, 0) processMonth, isnull(rc.TRXDATE, 0) processDate, isnull(rc.ACA_RID_Tax_Status, 0) taxStatus
	from dbo.fnIetuGetCobroRM(@VCHRNMBR, @DOCTYPE) rm
		left join ACA_RID10000 rc						--control de reclasificiaciones de impuestos
		on rc.TXDTLTYP = 1								--ventas
		and rc.DOCTYPE = rm.RMDTYPAL
		and rc.VCHRNMBR = rm.DOCNUMBR
		and rc.ACA_RID_Last = 1
	where @SOURCEDOC in ('CRJ', 'RMJ')
	
	union all

	--Facturas SOP pagadas simultáneamente
	select cast('CS' as varchar(2)) origenDoc, rm.txrgnnum, '', rm.RMDTYPAL, '',
		'', rm.VOIDstts,					--'pago anulado?
		1, 0, 
		-round(sum( case when isnull(im.taxdtlid, '@no existe') = '@no existe' 
						then 0.0
						else 
							case when rm.VOIDstts = 0 
								then rm.ortrxamt / (1 + dbo.fnPorcentajeImpuesto (im.taxdtlid)) 
								else 0.0
							end
					end	)
				, 2) slsamntProporcional,
		1 processType, min(isnull(rc.YEAR1, 0)) processYear, min(isnull(rc.MONTHINTERVAL, 0)) processMonth, min(isnull(rc.TRXDATE, 0)) processDate, min(isnull(rc.ACA_RID_Tax_Status, 0)) taxStatus
	from vwRmTransaccionesTodas rm			-- pago [CUSTNMBR, DOCNUMBR, RMDTYPAL]
	inner join vwRmTrxAplicadas ap			--[APTODCNM, APTODCTY, APFRDCNM, APFRDCTY]
		ON rm.docnumbr = ap.APFRDCNM
       and rm.rmdtypal = ap.APFRDCTY
    INNER JOIN vwRmTransaccionesTodas rmat	-- factura [CUSTNMBR, DOCNUMBR, RMDTYPAL]
		ON rmat.docnumbr = ap.APTODCNM
       and rmat.rmdtypal = ap.APTODCTY
	left join tx00102 im					--tx_schedule_mstr [taxschid, taxdtlid]
		on im.taxschid = rm.taxschid
	left join ACA_RID10000 rc				--control de reclasificiaciones de impuestos
		on rc.TXDTLTYP = 1					--ventas
		and rc.DOCTYPE = ap.APFRDCTY
		and rc.VCHRNMBR = ap.APFRDCNM
		and rc.ACA_RID_Last = 1
	where @SOURCEDOC = 'SJ'
	AND ap.APTODCNM = @VCHRNMBR
	and ap.APTODCTY = 1
	and rmat.cashamnt <> 0					--factura pagada simultáneamente
	group by rm.txrgnnum, rm.RMDTYPAL, rm.VOIDstts

	union all
	
	--reclasificaciones y reversiones de impuestos en cobros
	select cast('RC' as varchar(2)) origenDoc, rm.txrgnnum, rm.USERDEF1, rm.RMDTYPAL, rm.DOCNUMBR,
		'' poprctnm, rm.VOIDstts, rm.aplica_IETU, 0 prchamntProporcional, 0 slsamntProporcional,
		rc.TXDTLTYP processType, rc.YEAR1 processYear, rc.MONTHINTERVAL processMonth, rc.TRXDATE processDate, rc.ACA_RID_Tax_Status taxStatus
	from ACA_RID10000 rc					--control de reclasificiaciones de impuestos
		outer apply dbo.fnIetuGetCobroRM(rc.vchrnmbr, rc.doctype ) rm	
	where rc.jrnentry = @JRNENTRY
	and rc.TXDTLTYP = 1		--ventas
	and rc.doctype = 9		--> @DOCTYPE indica 0 en la contabilidad CORREGIR!!!!!
	and rc.vchrnmbr = @VCHRNMBR 
	and @series = 2			-- financiero
	
	union all
	
	--reclasificaciones y reversiones de impuestos en pagos
	select cast('RP' as varchar(2)) origenDoc, pt.txrgnnum, pt.USERDEF1, pt.doctype, pt.vchrnmbr,
		pt.poprctnm, pt.voided, pt.aplica_IETU, 0 prchamntProporcional, 0 slsamntProporcional,
		rc.TXDTLTYP processType, rc.YEAR1 processYear, rc.MONTHINTERVAL processMonth, rc.TRXDATE processDate, rc.ACA_RID_Tax_Status taxStatus
	from ACA_RID10000 rc					--control de reclasificiaciones de impuestos
		outer apply dbo.fnIetuGetPagosPM(@VCHRNMBR, rc.doctype ) pt	
	where rc.jrnentry = @JRNENTRY
	and rc.TXDTLTYP = 2		--compras
	and rc.doctype = 6		--> @DOCTYPE indica 0 en la contabilidad CORREGIR!!!!! 
	and rc.vchrnmbr = @VCHRNMBR 
	and @series = 2			--financiero
)
go

IF (@@Error = 0) PRINT 'Creación exitosa de la función: fnGetDocumentoOriginal()'
ELSE PRINT 'Error en la creación de la función: fnGetDocumentoOriginal()'
GO
-------------------------------------------------------------------------------------------------
--TEST
--select *
--from fnGetDocumentoOriginal('0004363', 3, 'SJ')

----sp_columns vwPmTransaccionesTodas
--repetidos:
--select doctype, vchrnmbr
--from ACA_RID10000
--where aca_rid_last = 1
----vchrnmbr = '00000000000000090'
--group by doctype, vchrnmbr
--having count(*) > 0

