/****** Object:  Table [dbo].[topslot_listing]    Script Date: 10/11/2018 12:16:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[topslot_listing](
	[adid] [bigint] NULL,
	[subcategoryid] [int] NULL,
	[cityid] [int] NULL,
	[areaid] [int] NULL,
	[position] [int] NULL,
	[startdate] [datetime] NULL,
	[enddate] [datetime] NULL
) ON [PRIMARY]
GO
