/****** Object:  StoredProcedure [dbo].[Prc_get_project_hp]    Script Date: 10/11/2018 12:16:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Prc_get_project_hp]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[Prc_get_project_hp] AS'
END
GO
Alter procedure Prc_get_project_hp
(@cityid int =0,
 @rowstofetch int =10
)
as 
begin
set nocount on 
	select top (@rowstofetch) adtitle as projectname,areaname [location],cityname city,cityname as groupcity,
				displaybedroom dispbedroom ,displaypropertytype dispproperty ,dbo.Fn_Get_formatedprice(minprice) as minprice ,
				case when minprice= maxprice then '' else dbo.Fn_Get_formatedprice(maxprice) end as maxprice,
				a.displayarea disparea ,a.projectid,CONVERT(varchar(12),a.crdate,107) crdate,
				shortdesc,dbo.fn_get_ad_singleimage_bytag(b.adid,'elevation') imageurl,
				'https://www.sulekha.com'+adurl as url
	
	From projectbusinessmapping(nolock)a 
	join adsmaster(nolock) b on a.projectid = b.adid
	where a.status = 1 and cityid = @cityid and b.status = 1
	and customertype =  1036002
set nocount off 
end
GO
