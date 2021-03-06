/****** Object:  Table [dbo].[adedithistory]    Script Date: 10/11/2018 12:16:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[adedithistory](
	[rowid] [int] IDENTITY(1,1) NOT NULL,
	[adid] [bigint] NULL,
	[businessid] [int] NULL,
	[cityid] [int] NULL,
	[crdate] [datetime] NULL,
	[modifiedpid] [int] NULL,
	[modifiedemailid] [varchar](256) NULL,
	[action] [varchar](32) NULL,
	[editedattributes] [nvarchar](max) NULL,
PRIMARY KEY CLUSTERED 
(
	[rowid] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
