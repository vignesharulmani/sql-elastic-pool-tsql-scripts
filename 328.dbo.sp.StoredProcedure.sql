/****** Object:  StoredProcedure [dbo].[sp]    Script Date: 10/11/2018 12:16:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[sp] (@searchtext varchar(128)='')
as
SET @searchtext='%'+@searchtext+'%'
EXEC sp_stored_procedures @sp_name=@searchtext
GO
