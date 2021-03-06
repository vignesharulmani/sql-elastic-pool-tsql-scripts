/****** Object:  StoredProcedure [dbo].[prc_mng_projecttype]    Script Date: 10/11/2018 12:16:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_mng_projecttype]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[prc_mng_projecttype] AS'
END
GO
Alter procedure prc_mng_projecttype
@projectid bigint,
@businessid int,
@customerid int,
@campaignid int,
@mode int 
as
begin

declare @attributevalueid int = 0
declare @lv_projectid bigint = @projectid
declare @lv_businessid int = @businessid
declare @lv_customerid bigint = @customerid
declare @lv_campaignid bigint = @campaignid
declare @lv_mode int = @mode
declare @lv_isbuilder int = 0
declare @modifieddate datetime = getdate()

if @lv_campaignid > 0 /*Paid*/
	select @attributevalueid = 1055400 
else /*Prospect*/
	select @attributevalueid = 1055401,@lv_campaignid = 0,@lv_customerid = 0 ,@lv_mode = 0 


if exists (select top 1 1 from dbo.adsmaster am (nolock) where am.adid = @lv_projectid and am.businessid = @lv_businessid)
		set @lv_isbuilder = 1
		
if @lv_isbuilder = 1
begin		
	
	update am 
		set 
			am.admode = @lv_mode,
			am.campaignid = @lv_campaignid,
			am.customerid = @lv_customerid,
			am.modifieddate = @modifieddate
		from dbo.adsmaster am (nolock)
		where am.adid = @projectid
	
	update am 
		set am.modifieddate = @modifieddate
		from dbo.adsmedia am (nolock)
			where am.adid = @projectid
	
	/*For Recent sorting we are updating crdate in adsneedmapping table*/
	update anm 
		set 
			anm.mode = @lv_mode,
			anm.campaignid = @lv_campaignid,
			anm.crdate = @modifieddate,
			anm.modifieddate = @modifieddate
		from dbo.adsneedmapping anm (nolock)
			where anm.adid = @projectid
	
	update asam 
		set 
			asam.mode = @lv_mode,
			asam.campaignid = @lv_campaignid,
			asam.modifieddate = @modifieddate
		from dbo.adssubcatattributemapping asam (nolock)
			where asam.adid = @projectid

	
	update asm 
		set 
			asm.mode = @lv_mode,
			asm.campaignid = @lv_campaignid,
			asm.modifieddate = @modifieddate
		from dbo.adssubcatmapping asm (nolock)
			where asm.adid = @projectid

	update top(1) asam
		set 
			asam.attributevalueid = @attributevalueid
		from dbo.adssubcatattributemapping asam (nolock)
			where asam.adid = @projectid 
				and asam.attributeid = 295300 /*Project Type*/
				
end				


end
GO
