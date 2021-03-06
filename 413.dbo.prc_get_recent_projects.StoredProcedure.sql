/****** Object:  StoredProcedure [dbo].[prc_get_recent_projects]    Script Date: 10/11/2018 12:16:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_get_recent_projects]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[prc_get_recent_projects] AS'
END
GO
Alter procedure prc_get_recent_projects
(
@cityid int , @rowstofetch int
)
as 
begin
set nocount on;
	;with cte as (
	select 	row_number()over(order by e.crdate desc ) rowid,
			a.adid as projectid,
			adtitle projectname,
			a.areaname as location,
			a.cityname as city,
			'' groupcity,
			e.displaybedroom dispbedroom,
			e.displaypropertytype as dispproperty,
			e.minprice,
			e.maxprice,
			e.displayarea as disparea,
			'http://www.sulekha.com'+dbo.fn_get_projecturl('','','',a.adid,a.businessid) as url,
			e.crdate as crdate
		
	From adsmaster(nolock) a
	join adsneedmapping(nolock)b on a.adid = b.adid 
	join projectbusinessmapping(nolock) e on a.adid = e.projectid 
	where adclassification = 7 and a.cityid = @cityid
	and e.status = 1 and b.status = 1 and a.status = 1
	) 
	select * from cte 
	where rowid <= @rowstofetch
	
set nocount off;

end
GO
