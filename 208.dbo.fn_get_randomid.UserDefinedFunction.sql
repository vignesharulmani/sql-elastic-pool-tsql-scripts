/****** Object:  UserDefinedFunction [dbo].[fn_get_randomid]    Script Date: 10/11/2018 12:16:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create function [dbo].[fn_get_randomid]()  
returns float  
as  
BEGIN  
Declare @newid float  
select @newid= randid from vw_randomid  
--select rand(checksum(@newid))  
  
return (@newid)  
END
GO
