/****** Object:  StoredProcedure [dbo].[prc_get_ads_bizlistings]    Script Date: 10/11/2018 12:16:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_get_ads_bizlistings]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[prc_get_ads_bizlistings] AS'
END
GO
Alter procedure prc_get_ads_bizlistings
@cityid int
,@subcategoryid int 
,@businessids varchar(1024)
as
begin

declare @lv_cityid int = @cityid
,@lv_subcategoryid int = @subcategoryid
,@lv_businessids varchar(1024)=@businessids

;with getbiz
as
(
select top 10 
row_number() over (order by (select 1)) autoid,ss.value businessid
from string_split(@lv_businessids,',') ss
)
,getads
as
(
select 
row_number() over (partition by gb.businessid order by asm.createddate desc) rowid,
gb.autoid,asm.adid,gb.businessid,asm.price,am.custominfo
from dbo.adssubcatmapping asm (nolock)
	join getbiz gb on asm.businessid = gb.businessid
	join dbo.adsmaster am (nolock) on asm.adid = am.adid
where asm.adid > 0
and asm.subcategoryid =  @lv_subcategoryid
and asm.status = 1
and asm.cityid = @lv_cityid
--and asm.price > 0
)
select g.businessid,g.adid,
isnull(dbo.fn_calc_discount(convert(money,dbo.fn_extract_custominfo(g.custominfo,'Actual Price')),g.price),'100% Off') discount
/*
g.price offerprice,
convert(money,dbo.fn_extract_custominfo(g.custominfo,'Actual Price')) actualprice
*/
	from getads g 
where g.rowid = 1
and isnumeric(dbo.fn_extract_custominfo(g.custominfo,'Actual Price'))=1
order by g.autoid


end
GO
