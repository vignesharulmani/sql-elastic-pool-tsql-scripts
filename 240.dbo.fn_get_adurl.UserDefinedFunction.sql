create function fn_get_adurl(@adid bigint)
returns varchar(256)
as
begin

declare @returnvalue varchar(256)=''

select top 1 @returnvalue = adurl from dbo.adsmaster am (nolock) where am.adid = @adid

return(@returnvalue)

end