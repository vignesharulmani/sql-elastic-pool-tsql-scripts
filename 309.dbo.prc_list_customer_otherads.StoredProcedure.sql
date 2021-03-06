/****** Object:  StoredProcedure [dbo].[prc_list_customer_otherads]    Script Date: 10/11/2018 12:16:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[prc_list_customer_otherads]
@cityid int,                              
@areaid int=0,                              
@subcatid int, 
@addefid INT=0,                             
@needid int=0,                              
@needidattribute split_needidattribute readonly, 
@Localityfiltertable  split_localityfilter readonly,                            
@sortby varchar(16)='score',                              
@fromprice money=0,
@toprice money =0,
@RowsToFetch int=10,                              
@PageNo int=1 ,                              
@excludeadidtable split_adsid  readonly,
@IncludeSurroundingAreas BIT = 1,
@radius INT = 3,
@nearbyareacount tinyint =5,
@excludearea varchar(256)='',
@lat float = null,
@long float = null,
@includeadidtable split_adsid readonly                    
as                     
begin                    
                    
set nocount on
                                    
declare @tblarea table (rowid int identity,areaid int primary key with(ignore_dup_key = on)
							,isnearby int,radius real)

declare @attributevaluecount int = 1
 
if @areaid > 0
	insert into @tblarea(areaid,isnearby,radius)
		select @areaid,0,0

if exists (select top 1 1 from @Localityfiltertable)
	insert into @tblarea(areaid,isnearby,radius)
		select areaid,0,0 from @Localityfiltertable

     
 

/*City Page without attributes*/
if not exists (select top 1 1 from @tblarea) and not exists (select top 1 1 from @needidattribute)
begin
print 'enter 3'
		;With Ads_need                              
		as                              
		(                              
		select top(( @RowsToFetch * @pageno ))
			row_number() over (order by  oapc,mode desc,netsalevalue desc) as RowID,
			adid,cityid,mode,score,netsalevalue             
		from (
		select 
			1 as dup,
			row_number() over (partition by 
									case when isnull(a.campaignid,0) > 0 then campaignid else 999999999 end 
								order by adid desc) oapc,
			a.adid,a.cityid,a.mode,0 score ,a.campaignid,a.netsalevalue
		from dbo.adsNeedMapping(nolock)  a                     
		where (cityid=@cityid)  and (subcategoryid=@subcatid) 
		and not exists (select top 1 1 from @excludeadidtable ebt where a.adid=ebt.adid)                           
		and a.status = 1
		and exists (select top 1 1 from @includeadidtable iat where a.adid=iat.adid)
		) a where dup=1                              
		)                         
                         
		Insert into #adid(adid,rowid,score,mode,netsalevalue)                                     
		select top(( @RowsToFetch * @pageno))  
			b.adid,RowID,b.score,b.mode,b.netsalevalue
		from Ads_need b               
		where RowID > ((@PageNo - 1) * @RowsToFetch)    
		order by RowID
end



set nocount off

end
GO
