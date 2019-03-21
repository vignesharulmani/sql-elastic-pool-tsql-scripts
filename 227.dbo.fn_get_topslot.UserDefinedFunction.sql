Alter function fn_get_topslot(@adid bigint)
returns int
as
begin

declare @roundid int = 0

select @roundid = bm.roundid from bannermapping bm (nolock) where bm.adid = @adid 
and exists (select top 1 1 from attributevaluepriority avp (nolock) 
		where avp.attributevalueid = bm.bannertypeattributevalueid and avp.isactive = 1)
and bm.isactive = 1

if isnull(@roundid,0) = 0
	select @roundid = roundid from bannermapping bm (nolock) where adid = @adid 
	and isactive = 1
	

return (isnull(@roundid,0))

end