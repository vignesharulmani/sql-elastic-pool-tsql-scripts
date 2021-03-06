/****** Object:  StoredProcedure [dbo].[prc_mng_adsneedmapping]    Script Date: 10/11/2018 12:16:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_mng_adsneedmapping]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[prc_mng_adsneedmapping] AS'
END
GO
ALTER procedure prc_mng_adsneedmapping
@adid bigint,
@subcatid int = 0,
@addefid int = 0,
@needid int = 0,
@cityid int = 0,
@areaid int = 0,
@tvp_areanames split_areaname readonly,
@status int = 1,
@adclassification int = 4,
@type varchar(8)='assign'
as
begin

begin try

declare @minprice money = 0
,@mode tinyint = 0 
,@campaignid int = 0
,@netsalevalue smallint = 0
,@crdate date = getdate()
,@modifieddate datetime = getdate()


if exists (select top 1 1 from @tvp_areanames) and @type = 'assign'
begin

select top 1 
@subcatid = anm.subcategoryid,@addefid= anm.addefid,@needid= anm.needid,@cityid = anm.cityid,
@areaid = anm.areaid,@minprice = anm.minprice,@mode = anm.mode,@campaignid = anm.campaignid,
@netsalevalue = anm.netsalevalue,@status = anm.status,@crdate = anm.crdate 
from dbo.adsneedmapping anm (nolock) 
where anm.adid = @adid and anm.adclassification = @adclassification

insert into adsneedmapping(adid,subcategoryid,addefid,needid,cityid,minprice,crdate,mode
			,modifieddate,campaignid,netsalevalue,status,adclassification,areaid,areaname)
select
@adid,@subcatid,@addefid,@needid,@cityid,@minprice,@crdate,@mode
,@modifieddate,@campaignid,@netsalevalue,@status,@adclassification,ta.localityid,ta.localityname
from @tvp_areanames ta
where ta.localityid > 0
and not exists (select top 1 1 from dbo.adsneedmapping anm(nolock) where anm.adid = @adid
					and anm.cityid = @cityid and anm.areaid = ta.localityid
					and anm.subcategoryid = @subcatid and anm.needid = @needid
					and anm.addefid = @addefid and anm.adclassification = @adclassification)

end
else if @type = 'unassign' and @cityid > 0 and @subcatid > 0 and @needid > 0 and @addefid > 0 and @adclassification > 0
begin
	delete top(1) anm  from dbo.adsneedmapping anm (nolock)
	where anm.adid = @adid
		and anm.cityid = @cityid and anm.areaid = @areaid
		and anm.subcategoryid = @subcatid and anm.needid = @needid
		and anm.addefid = @addefid and anm.adclassification = @adclassification
end


end try
begin catch
	exec dbo.PRC_INSERT_ERRORINFO
end catch

end
GO
