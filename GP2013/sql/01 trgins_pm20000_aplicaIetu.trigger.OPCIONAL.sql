----------------------------------------------------------------------------------------
--Propósito. GTP ingresa facturas pm vía IM. Los siguientes objetos sql marcan una factura pm con el valor Aplica IETU
--
IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[spIetuMarcaFacturaPM]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
    DROP PROCEDURE dbo.spIetuMarcaFacturaPM;
GO
create PROCEDURE [dbo].spIetuMarcaFacturaPM
(
	@DOCTYPE smallint,
	@VCHRNMBR char(21),
	@ACA_Gasto tinyint = 1,
	@ACA_IVA tinyint = 1
)
--28/8/13 jcf Creación
AS
	SET NOCOUNT ON
begin try
	if not exists(select doctype from ACA_IETU00400	where DOCTYPE = @DOCTYPE and VCHRNMBR = @VCHRNMBR)
		INSERT INTO [ACA_IETU00400]
		(
		[DOCTYPE],
		[VCHRNMBR],
		[ACA_Gasto],
		[ACA_IVA]
		)
		VALUES
		(
		@DOCTYPE,
		@VCHRNMBR,
		@ACA_Gasto,
		@ACA_IVA
		)
end try
begin catch
	RETURN @@Error
end catch

GO

------------------------------------------------------------------------------------------------
IF OBJECT_ID ('trgins_pm20000_aplicaIetu','TR') IS NOT NULL
   DROP TRIGGER dbo.trgins_pm20000_aplicaIetu
GO

CREATE TRIGGER dbo.trgins_pm20000_aplicaIetu ON dbo.pm20000
AFTER INSERT
AS
--Propósito. Marca una factura con el valor: aplica IETU MEXICO
--Requisito. En GTP las facturas ingresan vía IM
--28/08/13 JCF Creación. 
--
begin try
	declare @DOCTYPE smallint,	@VCHRNMBR char(21)

	select top 1 @DOCTYPE = DOCTYPE, @VCHRNMBR = VCHRNMBR
	 FROM inserted 
	 
	 if @DOCTYPE = 1	--invoice
		 exec spIetuMarcaFacturaPM @DOCTYPE, @VCHRNMBR

end try
BEGIN catch
	declare @l_error nvarchar(2048)
	select @l_error = 'Error al marcar factura con valor ietu. [trgins_pm20000_aplicaIetu] ' + error_message()
	RAISERROR (@l_error , 16, 1)
end catch
go

-------------------------------------------------------------------------------------------------

grant execute on dbo.spIetuMarcaFacturaPM to dyngrp;
go
