/****** Object:  UserDefinedTableType [dbo].[split_image]    Script Date: 10/11/2018 12:16:25 PM ******/
CREATE TYPE [dbo].[split_image] AS TABLE(
	[imageurl] [varchar](1024) NULL,
	[tag] [varchar](128) NULL,
	[attributeid] [int] NULL,
	[attributevalueid] [int] NULL
)
GO
