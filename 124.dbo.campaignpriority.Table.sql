/****** Object:  Table [dbo].[campaignpriority]    Script Date: 2/20/2019 12:30:28 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[campaignpriority](
	[campaignid] [int] NOT NULL,
	[customerid] [int] NOT NULL,
	[cityid] [int] NOT NULL,
	[customertype] [int] NOT NULL,
	[businessid] [int] NOT NULL,
	[mode] [smallint] NOT NULL,
	[runrate] [float] NULL,
	[crdate] [datetime] NULL,
	[status] [int] NOT NULL,
 CONSTRAINT [PK_composite_campaignpriority] PRIMARY KEY CLUSTERED 
(
	[campaignid] ASC,
	[customerid] ASC,
	[cityid] ASC,
	[businessid] ASC,
	[mode] ASC,
	[customertype] ASC,
	[status] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
