CREATE function fn_get_useradscount(@advpid int,@cityid int,@status int)
returns int
as
begin

declare @outputvalue int = 0

select @outputvalue = sum(adscount) from useradscount uac (nolock)
where (uac.advpid = @advpid)
and (uac.cityid = @cityid or @cityid = 0)
and (uac.status = @status or @status = -2)

return (isnull(nullif(@outputvalue,''),0))

end
