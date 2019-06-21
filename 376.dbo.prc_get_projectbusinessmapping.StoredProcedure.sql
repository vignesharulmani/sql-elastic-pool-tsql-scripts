/****** Object:  StoredProcedure [dbo].[prc_get_projectbusinessmapping]    Script Date: 10/11/2018 12:16:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_get_projectbusinessmapping]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[prc_get_projectbusinessmapping] AS'
END
GO
Alter procedure prc_get_projectbusinessmapping
@businessid int,
@projectid int
as
begin

set nocount on;

select 
pbm.projectid,am.adtitle projectname,am.cityname,am.areaname
,pbm.customerid,pbm.campaignid,pbm.businessid,pbm.businessname
,pbm.customertype 
from dbo.projectbusinessmapping pbm (nolock)
	join dbo.adsmaster am (nolock) on pbm.projectid = am.adid
where (pbm.businessid = @businessid or pbm.projectid = @projectid)
and pbm.status = 1

set nocount off;

end
GO
