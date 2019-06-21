/****** Object:  Table [dbo].[adsfeature]    Script Date: 6/21/2019 8:16:59 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[adsfeature](
	[rowid] [int] IDENTITY(1,1) NOT NULL,
	[adid] [bigint] NULL,
	[highlights] [nvarchar](4000) NULL,
	[localityhighlights] [nvarchar](4000) NULL
) ON [PRIMARY]
GO