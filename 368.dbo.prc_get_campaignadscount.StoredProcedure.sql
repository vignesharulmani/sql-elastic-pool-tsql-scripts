/****** Object:  StoredProcedure [dbo].[prc_get_campaignadscount]    Script Date: 10/11/2018 12:16:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_get_campaignadscount]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[prc_get_campaignadscount] AS'
END
GO
ALTER PROCEDURE prc_get_campaignadscount
(@campaignid int)
AS 
BEGIN
SET NOCOUNT ON 

SELECT 
	 adclassification,
	 ISNULL([0],0)+isnull([1],0)+isnull([2],0)+isnull([3],0)+isnull([5],0) as totalads,
	 isnull([0],0) as 'disabled',isnull([1],0) as 'live',isnull([2],0) as 'deleted',
	 isnull([3],0)+isnull([5],0)  as 'expired',
	 dbo.fn_get_adclassificationname(adclassification) adclassificationname
FROM (SELECT adclassification,[status],SUM(adscount)adscount
	
	FROM campaignadscount (NOLOCK)
	WHERE campaignid = @campaignid
	GROUP BY adclassification,[status]

)temp
PIVOT (SUM(adscount) FOR [status] in ([0],[1],[2],[3],[5])) AS pvt

SET NOCOUNT OFF


END
GO
