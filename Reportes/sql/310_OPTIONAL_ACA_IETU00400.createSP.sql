--|--------------------------------------------------------------------------------
--| [ACA_IETU00400Insert] - Insert Procedure Script for ACA_IETU00400
--|--------------------------------------------------------------------------------
IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id (N'[dbo].[ACA_IETU00400Insert]') AND OBJECTPROPERTY(id, N'IsProcedure') = 1) DROP PROCEDURE [dbo].[ACA_IETU00400Insert]
GO

CREATE PROCEDURE [dbo].[ACA_IETU00400Insert]
(
	@MexFolioFiscal char(40),
	@DOCTYPE smallint,
	@VCHRNMBR char(21),
	@ACA_Gasto tinyint = 1,
	@ACA_IVA tinyint = 1
)
AS
	SET NOCOUNT ON
begin try
	INSERT INTO [ACA_IETU00400]
	(
		MexFolioFiscal,
		[DOCTYPE],
		[VCHRNMBR],
		[ACA_Gasto],
		[ACA_IVA]
	)
	VALUES
	(
		@MexFolioFiscal ,
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

--select * from ACA_IETU00400
--exec ACA_IETU00400Insert 1, '00000000000000171'

--sp_statistics aca_ietu00400

