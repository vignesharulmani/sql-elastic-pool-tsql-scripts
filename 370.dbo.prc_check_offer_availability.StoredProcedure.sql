/****** Object:  StoredProcedure [dbo].[prc_check_offer_availability]    Script Date: 10/11/2018 12:16:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_check_offer_availability]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[prc_check_offer_availability] AS'
END
GO
Alter procedure prc_check_offer_availability
@cityid int,
@subcategoryid int
as
begin

set nocount on;

declare @lv_cityid int = @cityid,
@lv_subcategoryid int = @subcategoryid,
@isexists int = 0

select top 1 @isexists = 1 from campaignadscount cac (nolock) 
where cac.campaignid > 0
and cac.cityid = @lv_cityid
and cac.subcategoryid = @lv_subcategoryid
and cac.adclassification = 2 
and cac.status = 1 


select isnull(@isexists,0) isexists

set nocount off;

end
GO
