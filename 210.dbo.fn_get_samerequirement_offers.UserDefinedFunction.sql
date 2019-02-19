/****** Object:  UserDefinedFunction [dbo].[fn_get_samerequirement_offers]    Script Date: 10/11/2018 12:16:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER function [dbo].[fn_get_samerequirement_offers](@cityid int,@areaid int
			,@mobilenumber varchar(16),@customerid int,@businessid int			,@price money,@subcategoryid int,@needid int,@addefid int
			,@excludeadid bigint)
returns varchar(max)
as
begin

declare @returnvalue varchar(max) = ''
,@lv_mobilenumber varchar(16) = isnull(@mobilenumber,'')
,@lv_customerid int = isnull(@customerid,0)

;with get_customer_ads
as
(
select top 1 am.adid from dbo.adsmaster am (nolock)
	join dbo.adsneedmapping anm (nolock) on am.adid = anm.adid
where 
(
am.mobileno = @lv_mobilenumber
or ((exists (select 1 where am.customerid = @lv_customerid and @lv_customerid > 0)))
)
and am.cityid = @cityid
and am.areaid = @areaid
and am.adid <> @excludeadid
and am.price = @price
and am.price > 0
and am.status in (1,2,4)
and anm.subcategoryid = @subcategoryid
and anm.needid = @needid
and anm.addefid = @addefid
)
	select top 1 @returnvalue += convert(varchar(max),asam.adid)
	from get_customer_ads asam (nolock)		

return(isnull(@returnvalue,''))


end
GO
