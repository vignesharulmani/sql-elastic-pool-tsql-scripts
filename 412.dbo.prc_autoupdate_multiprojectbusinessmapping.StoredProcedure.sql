/****** Object:  StoredProcedure [dbo].[prc_autoupdate_multiprojectbusinessmapping]    Script Date: 10/11/2018 12:16:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_autoupdate_multiprojectbusinessmapping]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[prc_autoupdate_multiprojectbusinessmapping] AS'
END
GO
Alter procedure prc_autoupdate_multiprojectbusinessmapping
@tvp_adids split_adsid readonly
as
begin

declare @tblproject table (projectid bigint,businessid int)

insert into @tblproject(projectid,businessid)
select distinct am.projectid,am.businessid
from dbo.adsmaster am (nolock)
	join @tvp_adids ta on am.adid = ta.adid
where am.projectid > 0
and am.subcategoryid = 9600

;with cte_get_live_ad_ranges
as
(
select am.projectid,am.businessid,
min(am.price) minprice,max(am.price) maxprice, min(anm.areavalue) minarea,max(anm.areavalue) maxarea
from dbo.adsmaster am (nolock)
	join dbo.adsneedmapping anm (nolock) on am.adid = anm.adid
	join @tblproject tp on am.projectid = tp.projectid and am.businessid = tp.businessid
where 
anm.adclassification = 6
and am.status = 1
group by am.projectid,am.businessid
)
update top(1) pbm
	set pbm.minprice = c.minprice,
		pbm.maxprice = c.maxprice,
		pbm.minareavalue = c.minarea,
		pbm.maxareavalue = c.maxarea,
		pbm.modifieddate = getdate()
from dbo.projectbusinessmapping pbm (nolock)
	join cte_get_live_ad_ranges c on pbm.projectid = c.projectid and pbm.businessid = c.businessid
	join @tblproject tp on pbm.projectid = tp.projectid and pbm.businessid = tp.businessid
where pbm.status = 1 


end
GO
