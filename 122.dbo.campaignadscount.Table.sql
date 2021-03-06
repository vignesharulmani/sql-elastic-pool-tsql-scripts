/****** Object:  Table [dbo].[campaignadscount]    Script Date: 2/20/2019 12:28:02 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[campaignadscount](
	[campaignid] [int] NOT NULL,
	[cityid] [int] NOT NULL,
	[subcategoryid] [int] NOT NULL,
	[adclassification] [int] NOT NULL,
	[status] [int] NOT NULL,
	[adscount] [int] NULL,
 CONSTRAINT [PK_composite_campaignadscount] PRIMARY KEY CLUSTERED 
(
	[campaignid] ASC,
	[cityid] ASC,
	[subcategoryid] ASC,
	[adclassification] ASC,
	[status] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
