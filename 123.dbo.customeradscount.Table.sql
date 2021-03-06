/****** Object:  Table [dbo].[customeradscount]    Script Date: 2/20/2019 12:29:03 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[customeradscount](
	[businessid] [int] NOT NULL,
	[customerid] [int] NOT NULL,
	[campaignid] [int] NOT NULL,
	[cityid] [int] NOT NULL,
	[status] [int] NOT NULL,
	[adscount] [int] NULL,
 CONSTRAINT [PK_composite_customeradscount] PRIMARY KEY CLUSTERED 
(
	[businessid] ASC,
	[customerid] ASC,
	[campaignid] ASC,
	[cityid] ASC,
	[status] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
