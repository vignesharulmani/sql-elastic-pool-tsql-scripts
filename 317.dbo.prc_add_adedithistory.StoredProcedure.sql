/****** Object:  StoredProcedure [dbo].[prc_add_adedithistory]    Script Date: 10/11/2018 12:16:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_add_adedithistory]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[prc_add_adedithistory] AS'
END
GO
Alter procedure [dbo].[prc_add_adedithistory]
@tvp_adids split_adsid readonly
,@businessid int
,@cityid int
,@modifiedpid int
,@modifiedemailid varchar(256)
,@action varchar(32)
,@editedattributes nvarchar(max)
,@adid bigint = 0
,@remarks varchar(1024)=''
as
begin

if @adid > 0
begin
insert into adedithistory(adid,businessid,cityid,crdate
,modifiedpid,modifiedemailid,action,editedattributes,remarks)
select @adid,@businessid,@cityid,getdate(),@modifiedpid
,@modifiedemailid,@action,@editedattributes,@remarks
end
else
begin
insert into adedithistory(adid,businessid,cityid,crdate
,modifiedpid,modifiedemailid,action,editedattributes,remarks)
select adid,@businessid,@cityid,getdate(),@modifiedpid
,@modifiedemailid,@action,@editedattributes,@remarks
from @tvp_adids where isnull(nullif(adid,''),0) > 0
end


end
GO
