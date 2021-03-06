/****** Object:  Table [dbo].[bannerdetail]    Script Date: 10/11/2018 12:16:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[bannerdetail](
	[bannerid] [int] NULL,
	[crdate] [datetime] NULL,
	[createdby] [varchar](128) NULL,
	[modifieddate] [datetime] NULL,
	[modifiedby] [varchar](1) NULL,
	[customerid] [int] NULL,
	[campaignid] [int] NULL,
	[cityid] [int] NULL,
	[areaids] [varchar](max) NULL,
	[needid] [int] NULL,
	[addefid] [int] NULL,
	[businessid] [int] NULL,
	[adid] [bigint] NULL,
	[bannertype] [varchar](128) NULL,
	[startdate] [date] NULL,
	[enddate] [date] NULL,
	[isactive] [bit] NULL,
	[displayareaid] [varchar](128) NULL,
	[sourcetable] [tinyint] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
