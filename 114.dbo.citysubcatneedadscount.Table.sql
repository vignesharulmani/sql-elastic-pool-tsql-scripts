/****** Object:  Table [dbo].[citysubcatneedadscount]    Script Date: 10/11/2018 12:16:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[citysubcatneedadscount](
	[cityid] [int] NOT NULL,
	[subcategoryid] [int] NOT NULL,
	[needid] [int] NOT NULL,
	[addefid] [int] NULL,
	[adscount] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[cityid] ASC,
	[subcategoryid] ASC,
	[needid] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
