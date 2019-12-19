IF OBJECT_ID ('dbo.fnPorcentajeImpuesto') IS NOT NULL
   DROP FUNCTION dbo.fnPorcentajeImpuesto
GO

create FUNCTION fnPorcentajeImpuesto (@p_idimpuesto varchar(20))
RETURNS numeric(19,5)
AS
BEGIN
   DECLARE @l_TXDTLPCT numeric(19,5)
   select @l_TXDTLPCT = round(TXDTLPCT/100, 2) from tx00201 where taxdtlid = @p_idimpuesto
   RETURN(@l_TXDTLPCT)
END
go

IF (@@Error = 0) PRINT 'Creación exitosa de la función: fnPorcentajeImpuesto()'
ELSE PRINT 'Error en la creación de la función: fnPorcentajeImpuesto()'
GO
