/****** Object:  StoredProcedure [dbo].[prc_list_adslistings_projectads]    Script Date: 10/11/2018 12:16:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_list_adslistings_projectads]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[prc_list_adslistings_projectads] AS'
END
GO
Alter procedure prc_list_adslistings_projectads
@projectid bigint,
@businessid int,
@status int
as                     
begin                    
                    
set nocount on


declare @lv_projectid bigint = @projectid, 
@lv_businessid int = @businessid,
@lv_status int = @status 

declare @tblprojectads table (adid bigint primary key)

if @lv_projectid > 0
	insert into @tblprojectads
		select am.adid from dbo.adsmaster am (nolock)
		where am.contentid > 0
		and (am.projectid > 0)
		and (am.status = @lv_status)
		and exists (select top 1 1 from dbo.projectbusinessmapping pbm (nolock) 
						where am.projectid = @lv_projectid 
						and pbm.businessid = @lv_businessid
						and pbm.status = 1)

;With Ads_need                              
		as                              
		(                              
		select 
			row_number() over ( order by 
									case 
										when a.status = 1 then 1 /*Live*/
										when a.status = 3 then 2 /*Expired*/
										when a.status = 2 then 3 /*Deleted*/
										when a.status = 0 then 4 /*Disabled*/
										else 5 end,crdate desc,adid desc) as RowID,
			adid,cityid,mode,netsalevalue             
		from (
		select 
			1 as dup,
			row_number() over (partition by 
									case when isnull(a.campaignid,0) > 0 then campaignid else 999999999 end 
								order by 
									case 
										when a.status = 1 then 1 /*Live*/
										when a.status = 3 then 2 /*Expired*/
										when a.status = 2 then 3 /*Deleted*/
										when a.status = 0 then 4 /*Disabled*/
										else 5 end,adid desc) oapc,
			a.adid,a.cityid,a.mode,a.campaignid,a.crdate,a.modifieddate createddate,a.netsalevalue,a.status
		from dbo.adsNeedMapping(nolock)  a                     
		where a.adid > 0
		and exists (select top 1 1 from @tblprojectads t where t.adid = a.adid)
		) a where dup=1                              
		)                         
                         
		Insert into #adid(adid,rowid,score,mode,netsalevalue)                                     
		select 
			b.adid,RowID,0 score,b.mode,b.netsalevalue
		from Ads_need b               
		order by RowID



set nocount off

end
GO
