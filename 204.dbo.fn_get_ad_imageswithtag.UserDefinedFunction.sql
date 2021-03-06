/****** Object:  UserDefinedFunction [dbo].[fn_get_ad_imageswithtag]    Script Date: 10/11/2018 12:16:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[fn_get_ad_imageswithtag](@adid bigint)  
returns varchar(4000)                  
as                  
begin                  
                  
declare @imageurl varchar(4000)=''                  
select @imageurl = @imageurl + imageurlwithtag from (
select top(12) mediaurl + '~' + isnull(tag,'') + '|' [imageurlwithtag] from dbo.adsmedia (nolock) where adid = @adid
and mediatypeid = 1
order by mediatagid
)X
        
set  @imageurl=substring(@imageurl,0,len(@imageurl))                 
        
return @imageurl                  
end
GO
