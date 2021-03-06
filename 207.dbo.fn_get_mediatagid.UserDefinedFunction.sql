/****** Object:  UserDefinedFunction [dbo].[fn_get_mediatagid]    Script Date: 10/11/2018 12:16:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fn_get_mediatagid](@tagname VARCHAR(256))
RETURNS  INT
AS
BEGIN
DECLARE @returnvalue INT = 0
SELECT	TOP 1 @returnvalue = Tagid 
FROM	mediatagmaster(NOLOCK)
WHERE	Tagname	=	@tagname or Tagurl = @tagname

RETURN(@returnvalue)
END
GO
