/****** Object:  Table [dbo].[mediatagmaster]    Script Date: 10/11/2018 12:16:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[mediatagmaster](
	[Tagid] [int] IDENTITY(1,1) NOT NULL,
	[Tagname] [varchar](128) NOT NULL,
	[Tagurl] [varchar](256) NULL
) ON [PRIMARY]
GO
