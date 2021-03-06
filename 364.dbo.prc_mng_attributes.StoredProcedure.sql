/****** Object:  StoredProcedure [dbo].[prc_mng_attributes]    Script Date: 10/11/2018 12:16:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_mng_attributes]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[prc_mng_attributes] AS'
END
GO
Alter procedure prc_mng_attributes
@adid bigint
,@needidattributes varchar(256)
,@modifiedpid int
,@modifiedemailid varchar(256)
,@action varchar(32)
as
begin

declare @tvp_adids as split_adsid

insert into @tvp_adids(adid)
	select @adid

/*Log AD History during update/delete*/
	exec dbo.prc_add_adshistory @userpid = @modifiedpid,@action=@action,@tvp_adids=@tvp_adids
		,@comments='prc_mng_attributes',@landingurl='prc_mng_attributes',@currenturl='prc_mng_attributes'
		,@sourceurl='',@ip='',@UserDevice='',@devicetype=''
	

/*Log AD Edit History during update/delete*/
	exec dbo.prc_add_adedithistory @tvp_adids=@tvp_adids,@businessid=0,@cityid=0
			,@modifiedpid=@modifiedpid,@modifiedemailid=@modifiedemailid
			,@action=@action,@editedattributes=@needidattributes,@remarks='prc_mng_attributes'

if @action = 'assign'
begin

insert into adssubcatattributemapping(
adid,subcategoryid,adattributemapid,attributevalueid
,cityid,areaid,price,mode,createddate,modifieddate
,isautomapped,campaignid,isexclude
,attributeid,netsalevalue,status
)
select 
asm.adid,asm.subcategoryid,0 adattributemapid,sa.attributevalueid 
,asm.cityid,asm.areaid,asm.price,asm.mode,getdate() createddate
,getdate() modifieddate,0 isautomapped,asm.campaignid,0 isexclude
,sa.attributeid,asm.netsalevalue,asm.status
from dbo.adssubcatmapping asm(nolock) 
	cross join dbo.SplitAttributes(@needidattributes,',',':',';' ) sa
where asm.adid = @adid
and not exists (select top 1 1 from adssubcatattributemapping asam (nolock) 
					where asam.adid = asm.adid 
						and asam.attributeid = sa.attributeid
						and asam.attributevalueid = sa.attributevalueid)

end
else if @action= 'unassign'
begin

delete asam from adssubcatattributemapping asam (nolock)
	join dbo.SplitAttributes(@needidattributes,',',':',';' ) sa on asam.attributeid = sa.attributeid
													and asam.attributevalueid = sa.attributevalueid
where asam.adid = @adid

end



end
GO
