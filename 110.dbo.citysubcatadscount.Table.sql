/****** Object:  Table [dbo].[citysubcatadscount]    Script Date: 10/11/2018 12:16:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[citysubcatadscount](
	[cityid] [int] NOT NULL,
	[subcategoryid] [int] NOT NULL,
	[adscount] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[cityid] ASC,
	[subcategoryid] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
