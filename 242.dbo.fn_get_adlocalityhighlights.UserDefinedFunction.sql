create function fn_get_adlocalityhighlights(@adid bigint)
returns nvarchar(4000)
as
begin

declare @outputvalue nvarchar(4000)=''

select top 1 @outputvalue = localityhighlights from dbo.adsfeature (nolock) where adid = @adid

return(isnull(@outputvalue,''))

end