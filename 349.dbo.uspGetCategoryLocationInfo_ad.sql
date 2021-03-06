/****** Object:  StoredProcedure [dbo].[uspGetCategoryLocationInfo_ad]    Script Date: 10/11/2018 12:16:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[uspGetCategoryLocationInfo_ad]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[uspGetCategoryLocationInfo_ad] AS'
END
GO
ALTER Procedure uspGetCategoryLocationInfo_ad 
@Isneed tinyint,
@Id Int
as
begin

set nocount on;

if @Isneed = 0
begin
;with cte
as
(
select distinct cityid,convert(varchar,areaid) areaid from citysubcatareaadscount (nolock) 
where subcategoryid = @Id
)
select c1.cityid,
(select c2.areaid + ',' from cte c2 where c1.cityid = c2.cityid for xml path(''))AreaIds
from cte c1
group by c1.cityid
end
else if @Isneed = 1
begin
;with cte
as
(
select distinct cityid,convert(varchar,areaid) areaid from citysubcatareaattributeadscount (nolock) 
where attributevalueid = @Id
)
select c1.cityid,
(select c2.areaid + ',' from cte c2 where c1.cityid = c2.cityid for xml path(''))AreaIds
from cte c1
group by c1.cityid
end

set nocount off;

end
GO
