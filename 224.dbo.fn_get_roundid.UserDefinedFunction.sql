Alter function fn_get_roundid(@bannertypeattributevalueid int)
returns int
as
begin

declare @roundid int = 0

	select top 1 @roundid = [priority] from attributevaluepriority avp (nolock) 
	where avp.attributevalueid = @bannertypeattributevalueid and avp.isactive = 1

return(isnull(nullif(@roundid,''),0))

end