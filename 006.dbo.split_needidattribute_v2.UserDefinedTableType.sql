/****** Object:  UserDefinedTableType [dbo].[split_needidattribute_v2]    Script Date: 10/11/2018 12:16:27 PM ******/
CREATE TYPE [dbo].[split_needidattribute_v2] AS TABLE(
	[attributeid] [int] NULL,
	[attribute] [varchar](max) NULL,
	[attributevalueid] [int] NULL,
	[attributevalue] [varchar](max) NULL,
	[isdistribution] [bit] NULL,
	[isfilterable] [bit] NULL,
	[iseditable] [bit] NULL
)
GO
