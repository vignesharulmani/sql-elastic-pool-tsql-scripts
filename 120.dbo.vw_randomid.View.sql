/****** Object:  View [dbo].[vw_randomid]    Script Date: 10/11/2018 12:16:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[vw_randomid]  
as  
select rand(checksum(NEWID())) as randid
GO
