/****** Object:  Table [dbo].[citysubcatattributeadscount]    Script Date: 10/11/2018 12:16:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[citysubcatattributeadscount](
	[cityid] [int] NOT NULL,
	[subcategoryid] [int] NOT NULL,
	[subcatattributemapid] [int] NULL,
	[attributeid] [int] NOT NULL,
	[attributevalueid] [int] NOT NULL,
	[adscount] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[cityid] ASC,
	[subcategoryid] ASC,
	[attributeid] ASC,
	[attributevalueid] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
