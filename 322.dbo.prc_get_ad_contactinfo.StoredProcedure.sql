/****** Object:  StoredProcedure [dbo].[prc_get_ad_contactinfo]    Script Date: 10/11/2018 12:16:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Alter procedure [dbo].[prc_get_ad_contactinfo]
@adid varchar(512),
@businessid int=0,
@isproject int = 0
as
begin

	if @isproject = 0
		select
		am.adid,am.contactname [Name],am.mobileno [MobileNo],am.emailid EmailId,am.countrycode
		from	dbo.adsmaster am (nolock)
		where	exists (select top 1 1 from string_split(@adid,',')ss where am.adid = ss.value)
	else if @isproject = 1
		select
		am.adid,am.contactname [Name],am.mobileno [MobileNo],am.emailid EmailId,am.countrycode,
		am.adtitle,ama.mediaurl brochure
		from	dbo.adsmaster am (nolock)
			left join dbo.adsmedia ama (nolock) on am.adid = ama.adid and ama.attributeid = 296500 /*Brochure download*/
		where	exists (select top 1 1 from string_split(@adid,',')ss where am.adid = ss.value)

end
GO
