/****** Object:  StoredProcedure [dbo].[prc_list_adslistings_buildergallery]    Script Date: 10/11/2018 12:16:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_list_adslistings_buildergallery]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[prc_list_adslistings_buildergallery] AS'
END
GO
Alter procedure [dbo].[prc_list_adslistings_buildergallery]
@cityid int,                              
@areaid int=0,                              
@subcatid int, 
@addefid INT=0,                             
@needid int=0,                              
@needidattribute split_needidattribute readonly, 
@Localityfiltertable   split_localityfilter readonly,                            
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
@adclassification int = 0                    
as                     
begin                    
                    
set nocount on

                                    
declare @tblarea table (rowid int identity,areaid int primary key with(ignore_dup_key = on)
							,isnearby int,radius real)

declare @attributevaluecount int = 1
declare @attributecount int = 1
declare @morerecords int = 1
 
if @areaid > 0
	insert into @tblarea(areaid,isnearby,radius)
		select @areaid,0,0

if exists (select top 1 1 from @Localityfiltertable)
	insert into @tblarea(areaid,isnearby,radius)
		select areaid,0,0 from @Localityfiltertable
     

/*City Page with attributes*/
if not exists (select top 1 1 from @tblarea) and exists (select top 1 1 from @needidattribute)
begin

		
		;With cte_CustomerBanners
		as
		(
		select 
		row_number() over (order by bm.rowid) RowId,
		a.adid,a.businessid
		from dbo.adssubcatmapping(nolock)  a
			join bannermapping bm (nolock) on bm.bannerid = a.adid                      
		where a.adid > 0 and a.businessid > 0
		and (a.cityid=@cityid) and (a.subcategoryid=@subcatid) 
		and a.status = 1 and bm.isactive = 1
		and exists (select top 1 1 from @needidattribute na 
						where bm.bannertypeattributevalueid=na.attributevalueid)
		)                
		Insert into #adid(adid,rowid)    
		select top(( @RowsToFetch * @pageno) + @morerecords)  
			b.adid,RowID
		from cte_CustomerBanners b  
			join dbo.adsmaster am (nolock) on b.adid = am.adid
		where b.RowID > ((@PageNo - 1) * @RowsToFetch) 
		order by b.RowID

end

/*Locality Page with attributes*/
else if exists (select top 1 1 from @tblarea) and exists (select top 1 1 from @needidattribute)
begin

		;With cte_CustomerBanners
		as
		(
		select 
		row_number() over (order by bm.rowid) RowId,
		a.adid,a.businessid
		from dbo.adssubcatmapping(nolock)  a
			join dbo.bannermapping bm (nolock) on bm.bannerid = a.adid                      
			join dbo.adsneedmapping anm (nolock) on a.adid = anm.adid
			inner join @tblarea ta on anm.areaid = ta.areaid
		where a.adid > 0 and a.businessid > 0
		and (a.cityid=@cityid) and (a.subcategoryid=@subcatid) 
		and a.status = 1 and bm.isactive = 1
		and exists (select top 1 1 from @needidattribute na 
						where bm.bannertypeattributevalueid=na.attributevalueid)
		)                
		Insert into #adid(adid,rowid)    
		select top(( @RowsToFetch * @pageno) + @morerecords)  
			b.adid,RowID
		from cte_CustomerBanners b  
			join dbo.adsmaster am (nolock) on b.adid = am.adid
		where b.RowID > ((@PageNo - 1) * @RowsToFetch) 
		order by b.RowID

end


set nocount off

end
GO
