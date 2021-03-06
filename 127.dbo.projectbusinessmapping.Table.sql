/****** Object:  Table [dbo].[projectbusinessmapping]    Script Date: 6/21/2019 8:21:33 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[projectbusinessmapping](
	[rowid] [int] IDENTITY(1,1) NOT NULL,
	[projectid] [bigint] NULL,
	[businessid] [int] NULL,
	[customerid] [int] NULL,
	[campaignid] [int] NULL,
	[customertype] [int] NULL,
	[minprice] [money] NULL,
	[maxprice] [money] NULL,
	[minareavalue] [int] NULL,
	[maxareavalue] [int] NULL,
	[displayprice] [varchar](128) NULL,
	[displayarea] [varchar](64) NULL,
	[displaybedroom] [varchar](64) NULL,
	[displaypropertytype] [varchar](512) NULL,
	[crdate] [datetime] NULL,
	[modifieddate] [datetime] NULL,
	[contactname] [varchar](128) NULL,
	[emailid] [varchar](128) NULL,
	[mobileno] [varchar](16) NULL,
	[status] [int] NULL,
	[businessname] [varchar](128) NULL,
	[businesstitleurl] [varchar](128) NULL,
	[businessurl] [varchar](128) NULL,
	[createdby] [varchar](128) NULL,
	[modifiedby] [varchar](128) NULL
) ON [PRIMARY]
GO