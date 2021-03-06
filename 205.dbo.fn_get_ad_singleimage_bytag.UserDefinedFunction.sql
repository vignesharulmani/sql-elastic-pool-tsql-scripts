/****** Object:  UserDefinedFunction [dbo].[fn_get_ad_singleimage_bytag]    Script Date: 10/11/2018 12:16:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Alter function [dbo].[fn_get_ad_singleimage_bytag](@adid bigint,@tagurl varchar(64))
returns varchar(512)
as
begin

declare @returnvalue varchar(512)=''
declare @lv_adid bigint = @adid

if exists (select top 1 1 from dbo.adsmaster am (nolock) where am.adid = @lv_adid and am.projectid > 0)
begin
	select top 1 @lv_adid = am.projectid from dbo.adsmaster am (nolock) 
	where am.adid = @lv_adid and am.projectid > 0
end

select top 1 @returnvalue = mediaurl 
	from dbo.adsmedia (nolock) where adid = @lv_adid and tag = @tagurl and mediatypeid = 1

if isnull(@returnvalue,'')='' and @tagurl= 'elevation'
	select top 1 @returnvalue = mediaurl 
		from dbo.adsmedia (nolock) where adid = @lv_adid and tag = 'main-photo' and mediatypeid = 1

if isnull(@returnvalue,'')=''
	select top 1 @returnvalue = mediaurl 
		from dbo.adsmedia (nolock) where adid = @lv_adid and mediatypeid = 1
		and mediaurl not like '%pdf'

return(@returnvalue)
end
GO
