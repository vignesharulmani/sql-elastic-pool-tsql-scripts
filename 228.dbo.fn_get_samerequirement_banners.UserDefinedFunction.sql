/****** Object:  UserDefinedFunction [dbo].[fn_get_samerequirement_banners]    Script Date: 10/11/2018 12:16:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Alter function [dbo].[fn_get_samerequirement_banners](@cityid int,@tvp_areanames split_areaname readonly			,@businessid int,@bannertypeid int,@subcategoryid int,@needid int,@addefid int
			,@excludeadid bigint)
returns varchar(max)
as
begin

declare @returnvalue varchar(max) = ''
declare @topslotattributevalue table (attributevalueid int)
declare @includeattributevalue table (attributevalueid int)


/*Include Titanium & Platinum Banners*/
insert into @topslotattributevalue(attributevalueid)
select avp.attributevalueid from attributevaluepriority avp (nolock) 
where avp.subcategoryid = @subcategoryid 
and avp.attributevalueid = @bannertypeid
and avp.attributevalue in ('Titanium','Platinum 1','Platinum 2','Platinum 3')
and avp.isactive = 1


/*Include Premium Gallery*/
insert into @includeattributevalue(attributevalueid)
select avp.attributevalueid from attributevaluepriority avp (nolock) 
where avp.subcategoryid = @subcategoryid 
and avp.attributevalueid = @bannertypeid
and avp.attributevalue = 'Premium Gallery'
and avp.isactive = 1

if exists (select top 1 1 from @topslotattributevalue)
select top 1 @returnvalue += convert(varchar(max),anm.adid)
from dbo.adsneedmapping anm (nolock)
	join dbo.bannermapping bm (nolock) on anm.adid = bm.bannerid
where anm.adid > 0
and anm.cityid = @cityid
and anm.areaid > 0
and anm.subcategoryid = @subcategoryid
and anm.needid = @needid 
and anm.addefid = @addefid
and anm.adclassification = 4
and anm.status = 1
and bm.bannertypeattributevalueid = @bannertypeid
and bm.isactive = 1
and exists (select top 1 1 from @tvp_areanames ta where ta.localityid = anm.areaid)
and exists (select top 1 1 from @topslotattributevalue avp  
				where avp.attributevalueid = bm.bannertypeattributevalueid)
else if exists (select top 1 1 from @includeattributevalue)
select top 1 @returnvalue += convert(varchar(max),anm.adid)
from dbo.adsneedmapping anm (nolock)
	join dbo.bannermapping bm (nolock) on anm.adid = bm.bannerid
where anm.adid > 0
and anm.cityid = @cityid
and anm.areaid > 0
and anm.subcategoryid = @subcategoryid
and anm.needid = @needid 
and anm.addefid = @addefid
and anm.adclassification = 4
and anm.status = 1
and bm.bannertypeattributevalueid = @bannertypeid
and bm.isactive = 1
and exists (select top 1 1 from @tvp_areanames ta where ta.localityid = anm.areaid)
and exists (select top 1 1 from @includeattributevalue avp  
				where avp.attributevalueid = bm.bannertypeattributevalueid)
and exists (select top 1 1 from dbo.adssubcatmapping asm (nolock) 
				where asm.adid = bm.bannerid and asm.businessid = @businessid and asm.status = 1)

return(isnull(@returnvalue,''))


end
GO