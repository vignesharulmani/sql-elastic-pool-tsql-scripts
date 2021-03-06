/****** Object:  Table [dbo].[adsmaster]    Script Date: 10/11/2018 12:16:29 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[adsmaster](
	[contentid] [int] IDENTITY(1,1) NOT NULL,
	[adid] [bigint] NULL,
	[projectid] [int] NULL,
	[businessid] [int] NULL,
	[cityname] [varchar](64) NULL,
	[altcityname] [varchar](64) NULL,
	[areaname] [varchar](64) NULL,
	[altareaname] [varchar](64) NULL,
	[admode] [smallint] NULL,
	[adtitle] [varchar](256) NULL,
	[adurl] [varchar](256) NULL,
	[shortdesc] [varchar](4096) NULL,
	[price] [money] NULL,
	[displayarea] [varchar](64) NULL,
	[campaignid] [int] NULL,
	[customerid] [int] NULL,
	[latitude] [float] NULL,
	[longitude] [float] NULL,
	[streetname] [varchar](512) NULL,
	[zipcode] [varchar](64) NULL,
	[contactname] [varchar](128) NULL,
	[emailid] [varchar](128) NULL,
	[mobileno] [varchar](16) NULL,
	[phoneno] [varchar](16) NULL,
	[ctcphone] [varchar](16) NULL,
	[landmark] [varchar](256) NULL,
	[createddate] [datetime] NULL,
	[modifieddate] [datetime] NULL,
	[cityid] [int] NULL,
	[categoryid] [int] NULL,
	[subcategoryid] [int] NULL,
	[areaid] [int] NULL,
	[remarks] [varchar](256) NULL,
	[countrycode] [int] NULL,
	[subarea] [varchar](128) NULL,
	[buildingname] [varchar](128) NULL,
	[buildingno] [varchar](64) NULL,
	[address] [varchar](256) NULL,
	[paymentmode] [varchar](1024) NULL,
	[offer] [varchar](256) NULL,
	[custominfo] [nvarchar](max) NULL,
	[spadid] [int] NULL,
	[advpid] [int] NULL,
	[posteduserpid] [int] NULL,
	[completionscore] [float] NULL,
	[landingurl] [varchar](512) NULL,
	[currenturl] [varchar](512) NULL,
	[sourceurl] [varchar](512) NULL,
	[sourcekeyword] [varchar](128) NULL,
	[ip] [varchar](16) NULL,
	[useragent] [varchar](512) NULL,
	[devicetype] [varchar](128) NULL,
	[clienttype] [varchar](128) NULL,
	[pagesource] [varchar](64) NULL,
	[listdate] [datetime] NULL,
	[closedate] [datetime] NULL,
	[netsalevalue] [smallint] NULL,
	[status] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[contentid] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Index [nclx_adid_adsmaster]    Script Date: 10/11/2018 12:16:36 PM ******/
CREATE NONCLUSTERED INDEX [nclx_adid_adsmaster] ON [dbo].[adsmaster]
(
	[adid] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
GO
/****** Object:  Index [nclx_advpid_adsmaster]    Script Date: 10/11/2018 12:16:36 PM ******/
CREATE NONCLUSTERED INDEX [nclx_advpid_adsmaster] ON [dbo].[adsmaster]
(
	[advpid] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
GO
/****** Object:  Index [nclx_closedate_adsmaster]    Script Date: 10/11/2018 12:16:36 PM ******/
CREATE NONCLUSTERED INDEX [nclx_closedate_adsmaster] ON [dbo].[adsmaster]
(
	[closedate] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
GO
/****** Object:  Index [nclx_customerid_adsmaster]    Script Date: 10/11/2018 12:16:36 PM ******/
CREATE NONCLUSTERED INDEX [nclx_customerid_adsmaster] ON [dbo].[adsmaster]
(
	[customerid] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
GO
/****** Object:  Index [nclx_latitude_adsmaster]    Script Date: 10/11/2018 12:16:36 PM ******/
CREATE NONCLUSTERED INDEX [nclx_latitude_adsmaster] ON [dbo].[adsmaster]
(
	[latitude] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
GO
/****** Object:  Index [nclx_listdate_adsmaster]    Script Date: 10/11/2018 12:16:36 PM ******/
CREATE NONCLUSTERED INDEX [nclx_listdate_adsmaster] ON [dbo].[adsmaster]
(
	[listdate] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
GO
/****** Object:  Index [nclx_longitude_adsmaster]    Script Date: 10/11/2018 12:16:36 PM ******/
CREATE NONCLUSTERED INDEX [nclx_longitude_adsmaster] ON [dbo].[adsmaster]
(
	[longitude] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [nclx_mobileno_adsmaster]    Script Date: 10/11/2018 12:16:36 PM ******/
CREATE NONCLUSTERED INDEX [nclx_mobileno_adsmaster] ON [dbo].[adsmaster]
(
	[mobileno] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
GO
/****** Object:  Index [nclx_status_adsmaster]    Script Date: 10/11/2018 12:16:36 PM ******/
CREATE NONCLUSTERED INDEX [nclx_status_adsmaster] ON [dbo].[adsmaster]
(
	[status] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
GO
