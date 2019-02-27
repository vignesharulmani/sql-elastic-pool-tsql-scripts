create function fn_get_cityid_adid(@adid bigint)
returns int
as
begin

declare @cityid int = 0

if len(@adid) > 5
	set @cityid = left(@adid,4) - 1000

return(@cityid)

end