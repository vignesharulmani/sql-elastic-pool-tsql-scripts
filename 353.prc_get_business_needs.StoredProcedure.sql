/****** Object:  StoredProcedure [dbo].[prc_get_business_needs]    Script Date: 10/11/2018 12:16:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_get_business_needs]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[prc_get_business_needs] AS'
END
GO
Alter procedure prc_get_business_needs
@businessid int,
@cityid int
as
begin

set nocount on;

declare @bizneeds table (needid int primary key with (ignore_dup_key = on))

;with cte_asm
as
(
select asm.adid
from dbo.adssubcatmapping asm (nolock)
where asm.businessid = @businessid
and asm.cityid = @cityid
and asm.status = 1
),
cte_anm
as
(
	select 
		anm.needid
	from dbo.adsneedmapping anm (nolock)
		join cte_asm asm on anm.adid = asm.adid
	where anm.adid > 0
)
insert into @bizneeds(needid)
	select needid from cte_anm

select * from @bizneeds


set nocount off;

end
GO
