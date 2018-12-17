-------------------------------------------------------------------------------------------------
IF OBJECT_ID ('dbo.fnAplicaIETU') IS NOT NULL
   DROP FUNCTION dbo.fnAplicaIETU
GO

create function dbo.fnAplicaIETU(@VCHRNMBR varchar(21), @DOCTYPE smallint, @PAGOSIMULTANEO numeric(21,5))
returns table
as
--Propósito. 
--			EGRESOS: El campo aplica_IETU devuelve 1 si el pago aplica a gastos deducibles para ietu, o si el gasto aplica ietu. 
--				El campo prchamntProporcional devuelve la suma de los gastos aplicados.
--			Si entre las facturas aplicadas hay una que no es deducible, entonces aplica_IETU devuelve 0.
--			Este requerimiento es para México. Ver Proyecto Base de cálculo del IETU
--			INGRESOS: Todas las facturas de venta pagadas aplican ietu. 
--Requisitos. El indicador aplica Ietu está en una tabla externa ACA_IETU00400 (chunk IET_02.cnk)
--				ACA_Gasto          [tinyint]    (0-No aplica; 1-Aplica)
--				ACA_IVA            [tinyint]    (0-No aplica; 1-Aplica)
--25/07/12 jcf Creación 
--08/01/13 jcf Agrega campo voided_apfr para saber si el pago asociado a una factura está anulado
--
return
( 
	--PAGOS:
	--Devuelve 1 si el pago aplica a gastos que ingresan al ietu. 
	--También devuelve la suma de los gastos proporcionalmente aplicados
	select pa.VCHRNMBR, min(isnull(ti.ACA_Gasto, 0)) aplica_IETU, sum(pa.appldamt) appldamt, sum(pa.DOCAMNT) DOCAMNT, 
		sum(pa.voided_apfr) voided_apfr, sum(pa.prchamnt*pa.appldamt/pa.DOCAMNT) prchamntProporcional
	from tii_vwPmAplicadosExtendido pa		--pagos aplicados
	left join ACA_IETU00400 ti				--checkbox Aplica IETU
		on ti.DOCTYPE = pa.APTODCTY
		and ti.VCHRNMBR = pa.APTVCHNM
	where pa.[VCHRNMBR] = @VCHRNMBR		
	and pa.[DOCTYPE] = @DOCTYPE
	and @DOCTYPE >= 4						--4= Return, 5= Credit Memo, 6= payment
	group by pa.VCHRNMBR
	
	union all

	--FACTURAS:
	--Devuelve 1 si el gasto aplica ietu
	select ti.VCHRNMBR, isnull(ti.ACA_Gasto, 0) aplica_IETU, 0, 0, 0, 0
	from ACA_IETU00400  ti					--checkbox Aplica IETU
	where ti.DOCTYPE = @DOCTYPE
	and ti.VCHRNMBR = @VCHRNMBR
	and @DOCTYPE <= 3						--1= Invoice, 2= Finance Charge, 3= Miscellaneous Charges
	and @PAGOSIMULTANEO = 0					--facturas que no fueron pagadas simultáneamente

	union all

	--Caso de facturas pagadas simultáneamente
	select ti.VCHRNMBR, min(isnull(ti.ACA_Gasto, 0)) aplica_IETU, sum(isnull(pa.appldamt, 0)) appldamt, sum(isnull(pa.DOCAMNT, 0)) DOCAMNT, 
			sum(pa.voided_apfr), sum(isnull(pa.prchamnt, 0)*isnull(pa.appldamt, 0)/isnull(pa.DOCAMNT, 1)) prchamntProporcional
	from ACA_IETU00400 ti					--checkbox Aplica IETU
	left join tii_vwPmAplicadosExtendido pa	--pagos aplicados
		on ti.DOCTYPE = pa.APTODCTY
		and ti.VCHRNMBR = pa.APTVCHNM
	where ti.DOCTYPE = @DOCTYPE
	and ti.VCHRNMBR = @VCHRNMBR
	and @DOCTYPE <= 3						--1= Invoice, 2= Finance Charge, 3= Miscellaneous Charges
	and @PAGOSIMULTANEO <> 0
	group by ti.VCHRNMBR
)
go

IF (@@Error = 0) PRINT 'Creación exitosa de la función: fnAplicaIETU()'
ELSE PRINT 'Error en la creación de la función: fnAplicaIETU()'
GO
-------------------------------------------------------------------------------------------------
--TEST

	

--select *
--from ACA_IETU00400 

--sp_columns ACA_IETU00400
--sp_statistics ACA_IETU00400

--CRJ
--SJ
--RMJ
