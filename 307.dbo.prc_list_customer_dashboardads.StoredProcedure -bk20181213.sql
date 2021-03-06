/****** Object:  StoredProcedure [dbo].[prc_list_customer_dashboardads]    Script Date: 10/11/2018 12:16:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_list_customer_dashboardads]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[prc_list_customer_dashboardads] AS'
END
GO
Alter procedure prc_list_customer_dashboardads
@advpid int, 
@customerid int,
@businessid int = 0,
@campaignid int = 0, 
@cityid int,
@needid int,
@subcatid int,
@status int = -1,
@RowsToFetch int=10,                              
@PageNo int=1
as                     
begin                    
                    
set nocount on

print 'enter dashboard...'

declare @lv_customerid int = isnull(@customerid,0)
,@lv_businessid int = isnull(@businessid,0)
,@lv_campaignid int = isnull(@campaignid,0)
,@lv_cityid int = isnull(@cityid,0)
,@lv_advpid int = isnull(@advpid,0)
,@lv_status int = isnull(@status,-1)
,@lv_needid int = isnull(@needid,0)
,@lv_subcategoryid int = isnull(@subcatid,0)

declare @morerecords int = 1

declare @tblcustomerads table (adid int primary key)

	insert into @tblcustomerads
		select am.adid from adsmaster am (nolock)
		where (am.customerid = @lv_customerid or @lv_customerid = 0)
		and (am.businessid = @lv_businessid or @lv_businessid = 0)
		and (am.campaignid = @lv_campaignid or @lv_campaignid = 0)
		and (am.advpid = @lv_advpid or @lv_advpid = 0)
		and (am.status = @lv_status or @lv_status = -1)
		and am.cityid = @lv_cityid

;With Ads_need                              
		as                              
		(                              
		select top(( @RowsToFetch * @pageno )+@morerecords)
			row_number() over ( order by 
									case 
										when a.status = 1 then 1 /*Live*/
										when a.status = 3 then 2 /*Expired*/
										when a.status = 2 then 3 /*Deleted*/
										when a.status = 0 then 4 /*Disabled*/
										else 5 end,adid desc) as RowID,
			adid,cityid,mode,score,netsalevalue             
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
			a.adid,a.cityid,a.mode,0 score ,a.campaignid,a.modifieddate createddate,a.netsalevalue,a.status
		from dbo.adsNeedMapping(nolock)  a                     
		where a.adid > 0
		and exists (select top 1 1 from @tblcustomerads t where t.adid = a.adid)
		and (a.needid = @lv_needid or @lv_needid = 0)
		and (a.subcategoryid = @lv_subcategoryid or @lv_subcategoryid = 0)
		) a where dup=1                              
		)                         
                         
		Insert into #adid(adid,rowid,score,mode,netsalevalue)                                     
		select top(( @RowsToFetch * @pageno)+@morerecords)  
			b.adid,RowID,b.score,b.mode,b.netsalevalue
		from Ads_need b               
		where RowID > ((@PageNo - 1) * @RowsToFetch)    
		order by RowID



set nocount off

end
GO
