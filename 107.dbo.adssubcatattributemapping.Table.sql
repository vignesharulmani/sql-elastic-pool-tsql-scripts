/****** Object:  Table [dbo].[adssubcatattributemapping]    Script Date: 10/11/2018 12:16:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[adssubcatattributemapping](
	[rowid] [bigint] IDENTITY(1,1) NOT NULL,
	[adid] [bigint] NULL,
	[subcategoryid] [smallint] NULL,
	[adattributemapid] [int] NULL,
	[attributevalueid] [int] NULL,
	[cityid] [smallint] NULL,
	[areaid] [int] NULL,
	[price] [money] NULL,
	[mode] [tinyint] NULL,
	[createddate] [datetime] NULL,
	[modifieddate] [datetime] NULL,
	[isautomapped] [bit] NULL,
	[campaignid] [int] NULL,
	[isexclude] [bit] NULL,
	[attributeid] [int] NULL,
	[netsalevalue] [smallint] NULL,
	[status] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  Index [ix_rowid_adssubcatattributemapping]    Script Date: 10/11/2018 12:16:31 PM ******/
CREATE CLUSTERED INDEX [ix_rowid_adssubcatattributemapping] ON [dbo].[adssubcatattributemapping]
(
	[rowid] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
GO
/****** Object:  Index [nclx_adssubcatattributemapping_adid]    Script Date: 10/11/2018 12:16:36 PM ******/
CREATE NONCLUSTERED INDEX [nclx_adssubcatattributemapping_adid] ON [dbo].[adssubcatattributemapping]
(
	[adid] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
GO
/****** Object:  Index [nclx_adssubcatattributemapping_include_areaid]    Script Date: 10/11/2018 12:16:36 PM ******/
CREATE NONCLUSTERED INDEX [nclx_adssubcatattributemapping_include_areaid] ON [dbo].[adssubcatattributemapping]
(
	[subcategoryid] ASC,
	[cityid] ASC,
	[areaid] ASC,
	[status] ASC,
	[rowid] ASC
)
INCLUDE ( 	[adid],
	[attributevalueid],
	[price],
	[mode],
	[campaignid],
	[attributeid],
	[netsalevalue]) WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
GO
/****** Object:  Index [nclx_adssubcatattributemapping_include_cityid]    Script Date: 10/11/2018 12:16:36 PM ******/
CREATE NONCLUSTERED INDEX [nclx_adssubcatattributemapping_include_cityid] ON [dbo].[adssubcatattributemapping]
(
	[subcategoryid] ASC,
	[cityid] ASC,
	[status] ASC,
	[rowid] ASC
)
INCLUDE ( 	[adid],
	[attributevalueid],
	[price],
	[mode],
	[campaignid],
	[attributeid],
	[netsalevalue]) WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
GO
/****** Object:  Index [nclx_status_adssubcatattributemapping]    Script Date: 10/11/2018 12:16:36 PM ******/
CREATE NONCLUSTERED INDEX [nclx_status_adssubcatattributemapping] ON [dbo].[adssubcatattributemapping]
(
	[status] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
GO
