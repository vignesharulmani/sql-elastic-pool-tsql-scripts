/****** Object:  StoredProcedure [dbo].[prc_list_projectlistings_otherprojects]    Script Date: 10/11/2018 12:16:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_list_projectlistings_otherprojects]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[prc_list_projectlistings_otherprojects] AS'
END
GO
Alter procedure [dbo].[prc_list_projectlistings_otherprojects]
@cityid int,                              
@projectid bigint,
@businessid int                   
as                     
begin                    
                    
set nocount on

                                    
declare @tblarea table (rowid int identity,areaid int primary key with(ignore_dup_key = on)
							,isnearby int,radius real)

declare @attributevaluecount int = 1
declare @attributecount int = 1
declare @morerecords int = 1


declare
@lv_cityid int = @cityid, 
@lv_projectid bigint = @projectid,
@lv_businessid int = @businessid
 
     
 
/*Other projects of business*/
if @lv_projectid > 0 and @lv_businessid > 0
begin

		;With Ads_need                              
		as                              
		(     
		select pbm.projectid adid,
		row_number() over (order by pbm.crdate desc) rowid 
		from dbo.projectbusinessmapping pbm (nolock)                           
		where pbm.projectid <> @lv_projectid
		and pbm.businessid = @lv_businessid
		and pbm.status = 1
		and pbm.minprice > 0
		and exists (select top 1 1 from dbo.adsmaster am (nolock) 
					where am.projectid = pbm.projectid 
						and am.businessid = pbm.businessid
						and am.status = 1)
		)                
		Insert into #adid(adid,rowid)                                     
		select 
			b.adid,RowID
		from Ads_need b               
		order by RowID
end


set nocount off

end
GO
