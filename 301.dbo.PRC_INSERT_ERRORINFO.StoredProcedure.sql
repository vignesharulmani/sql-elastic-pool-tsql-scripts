/****** Object:  StoredProcedure [dbo].[PRC_INSERT_ERRORINFO]    Script Date: 10/11/2018 12:16:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PRC_INSERT_ERRORINFO]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[PRC_INSERT_ERRORINFO] AS'
END
GO
ALTER PROCEDURE [dbo].[PRC_INSERT_ERRORINFO]
AS
BEGIN
SET	NOCOUNT	ON
	
	DECLARE	@CUR_DATE		DATETIME	=	GETDATE()

	IF		OBJECT_ID('ERRORINFO') IS NOT NULL
	INSERT	INTO	errorinfo
	(
			errornumber,errorseverity,errorstate,errorprocedure,errorline,errormessage,createddate
	)
	SELECT	ERROR_NUMBER(),ERROR_SEVERITY(),ERROR_STATE(),ERROR_PROCEDURE(),ERROR_LINE(),ERROR_MESSAGE(),@CUR_DATE
	
SET	NOCOUNT	OFF
END

GO
