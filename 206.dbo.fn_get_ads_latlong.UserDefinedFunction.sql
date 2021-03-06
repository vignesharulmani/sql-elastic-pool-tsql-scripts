/****** Object:  UserDefinedFunction [dbo].[fn_get_ads_latlong]    Script Date: 10/11/2018 12:16:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[fn_get_ads_latlong](  
@cityid int,
@lat float,
@long float,                  
@radius int=5,                
@rowstofetch int=10  
)  
RETURNS @ads TABLE (adid bigint,radius real)  
BEGIN                   
                                       
  insert into @ads(adid,radius)	     
	  select top(@rowstofetch)adid,radius from (
	  SELECT  a.adid,
	  SQRT(POWER(69.1 * (a.latitude - @lat), 2) +                  
	  POWER(69.1 * (@long - a.longitude) * COS(a.latitude / 57.3), 2)) as radius                  
	  FROM adsmaster (nolock) a  
	  where cityid = @cityid and status = 1 and                  
	  SQRT(POWER(69.1 * (a.latitude - @lat), 2) +                  
	  POWER(69.1 * (@long - a.longitude) * COS(a.latitude / 57.3), 2)) < @radius       
	  )x
	  order by radius
                
                         
  
RETURN                            
END
GO
