/****** Object:  Table [dbo].[adssubcatmapping]    Script Date: 10/11/2018 12:16:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[adssubcatmapping](
	[rowid] [int] IDENTITY(1,1) NOT NULL,
	[adid] [bigint] NOT NULL,
	[categoryid] [int] NULL,
	[subcategoryid] [smallint] NULL,
	[cityid] [smallint] NULL,
	[areaid] [int] NULL,
	[mode] [int] NULL,
	[price] [money] NULL,
	[createddate] [datetime] NULL,
	[modifieddate] [datetime] NULL,
	[campaignid] [int] NULL,
	[spcategoryid] [int] NULL,
	[netsalevalue] [smallint] NULL,
	[businessid] [int] NULL,
	[status] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[adid] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Index [nclx_status_adssubcatmapping]    Script Date: 10/11/2018 12:16:36 PM ******/
CREATE NONCLUSTERED INDEX [nclx_status_adssubcatmapping] ON [dbo].[adssubcatmapping]
(
	[status] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
GO
/****** Object:  Index [nclx_subcategoryid_adssubcatmapping]    Script Date: 10/11/2018 12:16:36 PM ******/
CREATE NONCLUSTERED INDEX [nclx_subcategoryid_adssubcatmapping] ON [dbo].[adssubcatmapping]
(
	[subcategoryid] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
GO
/****** Object:  Index [nclx_cityid_adssubcatmapping]    Script Date: 10/11/2018 12:16:36 PM ******/
CREATE NONCLUSTERED INDEX [nclx_cityid_adssubcatmapping] ON [dbo].[adssubcatmapping]
(
	[cityid] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
GO
/****** Object:  Index [nclx_areaid_adssubcatmapping]    Script Date: 10/11/2018 12:16:36 PM ******/
CREATE NONCLUSTERED INDEX [nclx_areaid_adssubcatmapping] ON [dbo].[adssubcatmapping]
(
	[areaid] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
GO
/****** Object:  Index [nclx_campaignid_adssubcatmapping]    Script Date: 10/11/2018 12:16:36 PM ******/
CREATE NONCLUSTERED INDEX [nclx_campaignid_adssubcatmapping] ON [dbo].[adssubcatmapping]
(
	[campaignid] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
GO
/****** Object:  Index [nclx_businessid_adssubcatmapping]    Script Date: 10/11/2018 12:16:36 PM ******/
CREATE NONCLUSTERED INDEX [nclx_businessid_adssubcatmapping] ON [dbo].[adssubcatmapping]
(
	[businessid] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
GO

