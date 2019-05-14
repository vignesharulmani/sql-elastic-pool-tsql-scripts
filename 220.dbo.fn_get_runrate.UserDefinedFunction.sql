Alter function fn_get_runrate(@businessid int,@cityid int,@customerid int,@campaignid int)
returns float
as
begin

declare @returnvalue float = 0

select top 1 @returnvalue = runrate from campaignpriority cp (nolock)
where cp.cityid = @cityid
and (cp.campaignid = @campaignid)
and cp.status = 1

return (isnull(nullif(@returnvalue,''),0))

end