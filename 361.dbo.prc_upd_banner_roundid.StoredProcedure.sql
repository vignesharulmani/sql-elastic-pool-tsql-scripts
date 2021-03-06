/****** Object:  StoredProcedure [dbo].[prc_upd_banner_roundid]    Script Date: 10/11/2018 12:16:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_upd_banner_roundid]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[prc_upd_banner_roundid] AS'
END
GO
Alter procedure prc_upd_banner_roundid
as
begin

set nocount on;


declare @includeattributevalue table (attributevalueid int)
declare @tbl_totalcount_cityid table(counts int,cityid int)
declare @tbl_firstrowid_cityid table(rowid int,cityid int)

declare @max_roundid_premiumgallery int = 0

/*Include Premium Gallery*/
insert into @includeattributevalue(attributevalueid)
select avp.attributevalueid from attributevaluepriority avp (nolock) where avp.isactive = 1
and avp.attributevalueid = 978104

select @max_roundid_premiumgallery  = max(roundid) from bannermapping bm (nolock)
where bm.isactive = 1 
and bm.roundid > 0
and exists (select top 1 1 from @includeattributevalue ea 
			where ea.attributevalueid = bm.bannertypeattributevalueid)

/*Below logic is for campaign transfered banners*/
;with cte
as
(
select bm.rowid,bm.roundid, 
row_number() over (order by bm.rowid) + @max_roundid_premiumgallery [derived_roundid]
from bannermapping bm (nolock)
where bm.isactive = 1
and exists (select top 1 1 from @includeattributevalue ea 
					where ea.attributevalueid = bm.bannertypeattributevalueid)
and bm.roundid = 0
)
update cte
	set roundid = derived_roundid


insert into @tbl_totalcount_cityid(counts,cityid)
select count(1),bm.cityid from dbo.bannermapping bm (nolock)
where bm.roundid > 0 and bm.isactive = 1
and exists (select top 1 1 from @includeattributevalue ea 
					where ea.attributevalueid = bm.bannertypeattributevalueid)
group by bm.cityid

insert into @tbl_firstrowid_cityid(rowid,cityid)
select min(rowid),bm.cityid from dbo.bannermapping bm (nolock)
where bm.roundid > 0 and bm.isactive = 1
and exists (select top 1 1 from @includeattributevalue ea 
					where ea.attributevalueid = bm.bannertypeattributevalueid)
group by bm.cityid

update bm 
	set bm.roundid = tc.counts
from dbo.bannermapping bm (nolock)
	join @tbl_firstrowid_cityid fr on bm.rowid = fr.rowid
	join @tbl_totalcount_cityid tc on fr.cityid = tc.cityid
where exists (select top 1 1 from @includeattributevalue ea 
					where ea.attributevalueid = bm.bannertypeattributevalueid)
and bm.isactive = 1

update bm
	set roundid = roundid - 1
from dbo.bannermapping bm (nolock)
where not exists (select top 1 1 from @tbl_firstrowid_cityid fr where bm.rowid = fr.rowid)
and exists (select top 1 1 from @includeattributevalue ea 
					where ea.attributevalueid = bm.bannertypeattributevalueid)
and bm.isactive = 1

set nocount off;

end
GO
