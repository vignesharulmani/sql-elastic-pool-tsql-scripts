/****** Object:  Table [dbo].[adsneedmapping]    Script Date: 10/11/2018 12:16:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[adsneedmapping](
	[rowid] [int] IDENTITY(1,1) NOT NULL,
	[adid] [bigint] NULL,
	[subcategoryid] [smallint] NULL,
	[addefid] [int] NULL,
	[needid] [int] NULL,
	[cityid] [int] NULL,
	[areaid] [int] NULL,
	[minprice] [decimal](18, 0) NULL,
	[crdate] [date] NULL,
	[mode] [tinyint] NULL,
	[modifieddate] [datetime] NULL,
	[campaignid] [int] NULL,
	[netsalevalue] [smallint] NULL,
	[status] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[rowid] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Index [nclx_addefid_adsneedmapping]    Script Date: 10/11/2018 12:16:36 PM ******/
CREATE NONCLUSTERED INDEX [nclx_addefid_adsneedmapping] ON [dbo].[adsneedmapping]
(
	[addefid] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
GO
/****** Object:  Index [nclx_adsneedmapping_adid]    Script Date: 10/11/2018 12:16:36 PM ******/
CREATE NONCLUSTERED INDEX [nclx_adsneedmapping_adid] ON [dbo].[adsneedmapping]
(
	[adid] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
GO
/****** Object:  Index [nclx_areaid_adsneedmapping]    Script Date: 10/11/2018 12:16:36 PM ******/
CREATE NONCLUSTERED INDEX [nclx_areaid_adsneedmapping] ON [dbo].[adsneedmapping]
(
	[areaid] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
GO
/****** Object:  Index [nclx_minprice_adsneedmapping]    Script Date: 10/11/2018 12:16:36 PM ******/
CREATE NONCLUSTERED INDEX [nclx_minprice_adsneedmapping] ON [dbo].[adsneedmapping]
(
	[minprice] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
GO
/****** Object:  Index [nclx_needid_adsneedmapping]    Script Date: 10/11/2018 12:16:36 PM ******/
CREATE NONCLUSTERED INDEX [nclx_needid_adsneedmapping] ON [dbo].[adsneedmapping]
(
	[needid] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
GO
/****** Object:  Index [nclx_status_adsneedmapping]    Script Date: 10/11/2018 12:16:36 PM ******/
CREATE NONCLUSTERED INDEX [nclx_status_adsneedmapping] ON [dbo].[adsneedmapping]
(
	[status] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
GO
/****** Object:  Index [nclx_subcategoryid_adsneedmapping]    Script Date: 10/11/2018 12:16:36 PM ******/
CREATE NONCLUSTERED INDEX [nclx_subcategoryid_adsneedmapping] ON [dbo].[adsneedmapping]
(
	[subcategoryid] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
GO
