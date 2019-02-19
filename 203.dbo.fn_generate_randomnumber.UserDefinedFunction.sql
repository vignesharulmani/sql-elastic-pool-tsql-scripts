/****** Object:  UserDefinedFunction [dbo].[fn_generate_randomnumber]    Script Date: 10/11/2018 12:16:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[fn_generate_randomnumber](@minval int,@maxval int)  
returns int  
as  
begin  
  
return (CAST(((@maxval + 1) - @minval) * dbo.fn_get_randomid()+ @minval as int))  
  
end
GO
