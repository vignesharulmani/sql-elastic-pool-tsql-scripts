/****** Object:  StoredProcedure [dbo].[prc_get_adscount_realtime]    Script Date: 10/11/2018 12:16:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_get_adscount_realtime]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[prc_get_adscount_realtime] AS'
END
GO
Alter procedure prc_get_adscount_realtime
@cityid int,                          
@areaid int,                          
@subcatid int,                          
@addefid int=0,                          
@needid int=0,                          
@needidattribute split_needidattribute readonly
as
begin

--declare @needidattribute table(attributeid int, attributevalueid int)  
declare @attributecount int = 0
declare @returnvalue int = 0
declare @tblarea table (areaid int)

if @areaid > 0
begin

insert into @tblarea(areaid) values (@areaid)

insert into @tblarea(areaid)
	select agm.areaid from areagroupmaster agm (nolock) where agm.prominentroad_areaid = @areaid
	and not exists (select top 1 1 from @tblarea ta where ta.areaid = agm.areaid)

end  

Select @attributecount=count(distinct attributeid) from @needidattribute  

if isnull(@areaid,0) > 0
begin
		select 
			@returnvalue = sum(1)
		from (                              
		select 
			row_number() over (partition by a.adid order by a.adid) as dup
			,a.adid
			,count(a.attributeid) over (partition by a.adid) attributecount
		from dbo.adsSubcatAttributemapping(nolock) a 
			inner join @tblarea ta on a.areaid = ta.areaid
		where a.subcategoryid = @subcatid
		and a.cityid = @cityid
		--and a.areaid = @areaid
		and a.status = 1
		and a.rowid > 0
		and exists (select top 1 1 from @needidattribute na where na.attributeid=a.attributeid 
														and a.attributevalueid=na.attributevalueid)                                                            
		) a where a.dup=1 and a.attributecount = @attributecount
end
else
begin

		select 
			@returnvalue = count(adid)
		from (                              
		select 
			row_number() over (partition by a.adid order by a.adid) as dup
			,a.adid
			,count(a.attributeid) over (partition by a.adid) attributecount
		from dbo.adsSubcatAttributemapping(nolock) a 
		where a.subcategoryid = @subcatid
		and a.cityid = @cityid
		and a.status = 1
		and a.rowid > 0
		and exists (select top 1 1 from @needidattribute na where na.attributeid=a.attributeid 
														and a.attributevalueid=na.attributevalueid)                                                            
		) a where a.dup=1 and a.attributecount = @attributecount

end
		return @returnvalue;
end
GO
