/****** Object:  Table [dbo].[adshistory]    Script Date: 10/11/2018 12:16:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[adshistory](
	[rowid] [bigint] IDENTITY(1,1) NOT NULL,
	[logdate] [datetime] NULL,
	[userpid] [int] NULL,
	[action] [varchar](32) NULL,
	[AdId] [bigint] NULL,
	[versionno] [int] NULL,
	[comments] [varchar](512) NULL,
	[jsondata] [nvarchar](max) NULL,
	[landingurl] [varchar](512) NULL,
	[currenturl] [varchar](512) NULL,
	[sourceurl] [varchar](512) NULL,
	[ip] [varchar](16) NULL,
	[userdevice] [varchar](512) NULL,
	[devicetype] [varchar](512) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[adshistory] ADD  DEFAULT (getdate()) FOR [logdate]
GO
