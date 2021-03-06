/****** Object:  StoredProcedure [dbo].[prc_get_projectnames]    Script Date: 10/11/2018 12:16:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_get_projectnames]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[prc_get_projectnames] AS'
END
GO
Alter procedure prc_get_projectnames    
@cityid int,    
@areaid int,    
@businessid int = 0,
@needid int=0,
@pagesource varchar(32)='online'    
as    
begin    
    
set nocount on;    
    
declare @lv_cityid int = @cityid,    
@lv_areaid int = @areaid,    
@lv_businessid int = @businessid,  
@lv_needid int = @needid, 
@lv_pagesource varchar(32) =  @pagesource,  
@lv_displaypropertytype varchar(512)='',
@lv_displaypropertytype_house varchar(512)=''

if @lv_needid = 66300
	select @lv_displaypropertytype = '%Land%' 
else if @lv_needid = 62400
	select @lv_displaypropertytype = '%Commercial%'
else 
	select @lv_displaypropertytype = '%Flat%', @lv_displaypropertytype_house = '%House%'	 

    
declare @tblprojects table (rowid int identity,projectid bigint primary key with(ignore_dup_key = on),customertype int,isbuilder int)    
    
if @lv_cityid > 0 and @lv_areaid > 0  and @lv_pagesource = 'internal'  
begin    
 insert into @tblprojects(projectid,isbuilder)    
 select anm.adid,case when asm.businessid = @lv_businessid then 1 else 0 end    
 from dbo.adsneedmapping anm (nolock)
	join dbo.adssubcatmapping asm (nolock) on anm.adid = asm.adid    
 where anm.adid > 0    
   and anm.cityid=@lv_cityid    
   and anm.areaid=@lv_areaid    
   and anm.subcategoryid > 0    
   and anm.adclassification=7    
   and anm.status = 1    
end    
else if @lv_businessid > 0 and @lv_pagesource = 'online'     
begin    
     
 insert into @tblprojects(projectid,customertype)    
 select pbm.projectid,pbm.customertype from dbo.projectbusinessmapping pbm (nolock)    
	join dbo.adsneedmapping anm (nolock) on pbm.projectid = anm.adid
 where pbm.businessid = @lv_businessid    
 and pbm.status = 1    
 and pbm.customertype > 0
 and anm.adid > 0    
 and anm.cityid > 0
 and anm.areaid > 0
 and anm.subcategoryid > 0    
 --and (anm.needid = @lv_needid or @lv_needid  = 0)
 and anm.adclassification=7    
 and anm.status = 1  
 and (pbm.displaypropertytype like @lv_displaypropertytype  or pbm.displaypropertytype like @lv_displaypropertytype_house)  
    
 insert into @tblprojects(projectid) values (-1)    
    
end    
    
select tp.projectid,iif(tp.projectid=-1,'Others',am.adtitle) projectname, 
iif(tp.projectid=-1,'1035802',tp.customertype) customertype,
isnull(tp.isbuilder,0) isbuilder
from @tblprojects tp    
 left join dbo.adsmaster am (nolock) on am.adid = tp.projectid    
order by tp.rowid    
    
set nocount off;    
    
end
GO
