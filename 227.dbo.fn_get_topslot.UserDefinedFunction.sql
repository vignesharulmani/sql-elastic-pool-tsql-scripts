Alter function fn_get_topslot(@adid bigint)
returns int
as
begin

declare @roundid int = 0
declare @getdate datetime = getdate()

select @roundid = bm.roundid from dbo.bannermapping bm (nolock) where bm.adid = @adid 
and exists (select top 1 1 from dbo.attributevaluepriority avp (nolock) 
		where avp.attributevalueid = bm.bannertypeattributevalueid and avp.isactive = 1)
and bm.isactive = 1 and @getdate between bm.startdate and bm.enddate


if isnull(@roundid,0) = 0
	select @roundid = bm.roundid from dbo.bannermapping bm (nolock) where bm.adid = @adid 
	and bm.isactive = 1 and @getdate between bm.startdate and bm.enddate
	

return (isnull(@roundid,0))

end