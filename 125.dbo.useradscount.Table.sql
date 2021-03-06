/****** Object:  Table [dbo].[useradscount]    Script Date: 2/20/2019 12:31:12 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[useradscount](
	[advpid] [int] NOT NULL,
	[cityid] [int] NOT NULL,
	[status] [int] NOT NULL,
	[adscount] [int] NULL,
 CONSTRAINT [PK_composite_useradscount] PRIMARY KEY CLUSTERED 
(
	[advpid] ASC,
	[cityid] ASC,
	[status] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO


