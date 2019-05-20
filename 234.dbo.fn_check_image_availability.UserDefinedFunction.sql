create function fn_check_image_availability(@adid bigint)
returns int
as
begin

declare @isavailable int = 0 

if exists (select top 1 1 from dbo.adsmedia (nolock) where adid = @adid)
	set @isavailable = 1

return(@isavailable)

end