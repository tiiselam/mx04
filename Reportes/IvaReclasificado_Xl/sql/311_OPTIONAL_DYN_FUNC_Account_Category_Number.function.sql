/****** Object:  UserDefinedFunction [dbo].[DYN_FUNC_Account_Category_Number]    Script Date: 07/11/2012 11:58:03 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO

ALTER function [dbo].[DYN_FUNC_Account_Category_Number] (@iIntEnum integer) returns varchar(100) as  
begin  
declare @oVarcharValuestring varchar(100) 

select @oVarcharValuestring = accatdsc
from gl00102 mc			--gl_account_category_mstr
where accatnum = @iIntEnum

RETURN(@oVarcharValuestring)
END  
GO

--select *
--from GL00100
--where ACTNUMBR_3 like '101%'



