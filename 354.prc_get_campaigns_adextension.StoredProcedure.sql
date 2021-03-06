/****** Object:  StoredProcedure [dbo].[prc_get_campaigns_adextension]    Script Date: 10/11/2018 12:16:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_get_campaigns_adextension]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[prc_get_campaigns_adextension] AS'
END
GO
Alter procedure prc_get_campaigns_adextension  
@duration int = 1  
as  
begin  
  
set nocount on;  
  
declare @processdatetime datetime = getdate() + @duration  
  
select distinct am.campaignid from dbo.adsmaster am (nolock)  
 join dbo.adsneedmapping anm (nolock) on am.adid = anm.adid  
where am.closedate < @processdatetime  
and am.status = 1  
and am.campaignid > 0  
and anm.adclassification in (3,4,5,6,7) /*PG,Banner,Rental,Realestate,Project*/
  
set nocount off;  
  
end
GO
