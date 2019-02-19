/****** Object:  StoredProcedure [dbo].[prc_get_ad_contactinfo]    Script Date: 10/11/2018 12:16:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[prc_get_ad_contactinfo]
@adid varchar(512),
@businessid int=0
as
begin

	select
	am.adid,am.contactname [Name],am.mobileno [MobileNo],am.emailid EmailId
	from	adsmaster am (nolock)
	where	exists (select top 1 1 from string_split(@adid,',')ss where am.adid = ss.value)

end
GO
