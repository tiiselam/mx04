-------------------------------------------------------------------------------------------------
IF OBJECT_ID ('dbo.fnIetuGetCobroRM') IS NOT NULL
   DROP FUNCTION dbo.fnIetuGetCobroRM
GO

create function dbo.fnIetuGetCobroRM(@VCHRNMBR varchar(21), @DOCTYPE smallint)
returns table
as
--Propósito. Obtiene datos del cobro: manual o mcp
--Requisitos. 
--09/01/13 jcf Creación 
--
return
( 
	select rm.txrgnnum, '' USERDEF1, rm.RMDTYPAL, rm.DOCNUMBR, rm.VOIDstts, 
		1 aplica_IETU, 0 prchamntProporcional, 
		-round(sum( case when isnull(im.taxdtlid, '@no existe') = '@no existe' 
						then 0.0
						else rm.ortrxamt / (1 + dbo.fnPorcentajeImpuesto (im.taxdtlid))
					end	)
				, 2) slsamntProporcional
	from vwRmTransaccionesTodas rm			--[CUSTNMBR, DOCNUMBR, RMDTYPAL]
		left join tx00102 im				--tx_schedule_master [taxschid, taxdtlid]
		on im.taxschid = rm.taxschid
	where --@SOURCEDOC in ('CRJ', 'RMJ')
	rm.docnumbr = @VCHRNMBR	
	and rm.rmdtypal = @DOCTYPE
	group by rm.txrgnnum, rm.RMDTYPAL, rm.DOCNUMBR, rm.VOIDstts
)
go

IF (@@Error = 0) PRINT 'Creación exitosa de la función: fnIetuGetCobroRM()'
ELSE PRINT 'Error en la creación de la función: fnIetuGetCobroRM()'
GO
