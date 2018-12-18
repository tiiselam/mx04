
/****** Object:  UserDefinedFunction [dbo].[DYN_FUNC_Series_GL_Trx]    Script Date: 07/26/2012 13:02:42 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO

ALTER function [dbo].[DYN_FUNC_Series_GL_Trx] (@iIntEnum integer) returns varchar(100) as  begin  
declare @oVarcharValuestring varchar(100) 
set @oVarcharValuestring = case  
when @iIntEnum = 1 then 'Todo' 
when @iIntEnum = 2 then 'Financiero' 
when @iIntEnum = 3 then 'Ventas' 
when @iIntEnum = 4 then 'Compras' 
when @iIntEnum = 5 then 'Inventario' 
when @iIntEnum = 6 then 'Nómina' 
when @iIntEnum = 7 then 'Proyecto' 
else ''  end  
RETURN(@oVarcharValuestring)  END  
GO


