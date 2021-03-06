/****** Object:  StoredProcedure [dbo].[prc_list_adslistings_adid]    Script Date: 10/11/2018 12:16:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_list_adslistings_adid]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[prc_list_adslistings_adid] AS'
END
GO
Alter procedure prc_list_adslistings_adid
@adid bigint = 0,
@adidlists varchar(2048)=''
as                     
begin                    
                    
set nocount on

declare @tblads table (id int identity,adid bigint)

if @adid > 0
	insert into @tblads(adid) values (@adid)
else if isnull(@adidlists,'') > ''
	insert into @tblads(adid)
		select value from string_split(@adidlists,',')
		


;With Ads_need                              
		as                              
		(                              
		select 
			ta.id RowID
			,a.adid,a.mode,a.netsalevalue
		from dbo.adssubcatMapping(nolock)  a                     
			join @tblads ta on a.adid = ta.adid
		)                         
                         
		Insert into #adid(adid,rowid,score,mode,netsalevalue)                                     
		select 
			b.adid,RowID,0 score,b.mode,b.netsalevalue
		from Ads_need b               

set nocount off

end
GO
