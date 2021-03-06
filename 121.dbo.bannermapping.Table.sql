/****** Object:  Table [dbo].[bannermapping]    Script Date: 2/20/2019 12:27:01 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[bannermapping](
	[rowid] [int] IDENTITY(1,1) NOT NULL,
	[bannerid] [bigint] NOT NULL,
	[adid] [bigint] NOT NULL,
	[bannertypeattributevalueid] [int] NOT NULL,
	[roundid] [int] NULL,
	[isactive] [int] NOT NULL,
	[crdate] [datetime] NULL,
	[modifieddate] [datetime] NULL
) ON [PRIMARY]
GO
