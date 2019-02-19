create function fn_get_customeradscount(@businessid int,@customerid int,@campaignid int,@cityid int,@status int)
returns int
as
begin

declare @outputvalue int = 0

select @outputvalue = sum(adscount) from customeradscount cac (nolock)
where (cac.businessid = @businessid)
and (cac.customerid = @customerid or @customerid = 0)
and (cac.campaignid = @campaignid or @campaignid = 0)
and (cac.cityid = @cityid or @cityid = 0)
and (cac.status = @status or @status = -2)

return (isnull(nullif(@outputvalue,''),0))

end