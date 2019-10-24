Alter function fn_get_adlongdesc(@adid bigint)
returns varchar(max)
as
begin

declare @outputvalue varchar(max)=''

select top 1 @outputvalue = longdesc from dbo.adsfeature (nolock) where adid = @adid

return(isnull(@outputvalue,''))

end