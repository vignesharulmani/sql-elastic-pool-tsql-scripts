/****** Object:  Table [dbo].[adsmedia]    Script Date: 10/11/2018 12:16:29 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[adsmedia](
	[mediaid] [int] IDENTITY(1,1) NOT NULL,
	[adid] [bigint] NULL,
	[medianame] [varchar](256) NULL,
	[mediatypeid] [smallint] NULL,
	[mediaurl] [varchar](256) NULL,
	[mediacaption] [varchar](256) NULL,
	[tag] [varchar](128) NULL,
	[createddate] [datetime] NULL,
	[ishidden] [bit] NULL,
	[isfeatured] [bit] NULL,
	[isverified] [bit] NULL,
	[modifieddate] [datetime] NULL,
	[mediatagid] [int] NULL,
	[subcatattributemediatagid] [int] NULL,
	[attributeid] [int] NULL,
	[status] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[mediaid] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Index [nclx_adsmedia_adid]    Script Date: 10/11/2018 12:16:36 PM ******/
CREATE NONCLUSTERED INDEX [nclx_adsmedia_adid] ON [dbo].[adsmedia]
(
	[adid] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
GO
/****** Object:  Index [nclx_status_adsmedia]    Script Date: 10/11/2018 12:16:36 PM ******/
CREATE NONCLUSTERED INDEX [nclx_status_adsmedia] ON [dbo].[adsmedia]
(
	[status] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
GO
