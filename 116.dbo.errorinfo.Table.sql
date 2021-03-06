/****** Object:  Table [dbo].[errorinfo]    Script Date: 10/11/2018 12:16:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[errorinfo](
	[contentid] [int] IDENTITY(1,1) NOT NULL,
	[errornumber] [int] NULL,
	[errorseverity] [varchar](512) NULL,
	[errorstate] [varchar](512) NULL,
	[errorprocedure] [varchar](128) NULL,
	[errorline] [varchar](8) NULL,
	[errormessage] [varchar](1024) NULL,
	[createddate] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[contentid] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
