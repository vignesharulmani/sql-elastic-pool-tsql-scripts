/****** Object:  StoredProcedure [dbo].[prc_push_adstatus_ypuseranalysis]    Script Date: 10/11/2018 12:16:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_push_adstatus_ypuseranalysis]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[prc_push_adstatus_ypuseranalysis] AS'
END
GO
Alter procedure prc_push_adstatus_ypuseranalysis
as
begin

set nocount on;

declare @date date = getdate()

select asm.adid,asm.status,asm.campaignid,asm.businessid,am.customerid
from dbo.adssubcatmapping asm (nolock)
	join dbo.adsmaster am (nolock) on asm.adid = am.adid
where am.contentid > 0 and asm.modifieddate > @date


set nocount off;

end
GO
