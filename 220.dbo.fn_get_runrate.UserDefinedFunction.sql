create function fn_get_runrate(@businessid int,@cityid int,@customerid int,@campaignid int)
returns float
as
begin

declare @returnvalue float = 0

select top 1 @returnvalue = runrate from campaignpriority cp (nolock)
where (cp.businessid = @businessid or @businessid =0)
and cp.cityid = @cityid
and (cp.customerid = @customerid or @customerid = 0)
and (cp.campaignid = @campaignid or @campaignid = 0)
and cp.status = 1

return (isnull(nullif(@returnvalue,''),0))

end