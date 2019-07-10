create function fn_get_projectid_adid(@adid bigint)
returns bigint
as
begin

declare @projectid bigint = 0

select @projectid = projectid from dbo.adsmaster am (nolock) where am.adid = @adid and am.projectid > 0

return(isnull(@projectid,0))

end