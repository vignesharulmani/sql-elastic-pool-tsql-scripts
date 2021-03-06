/****** Object:  UserDefinedFunction [dbo].[SplitAttributes]    Script Date: 10/11/2018 12:16:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Function [dbo].[SplitAttributes] (@inputstring varchar(2000),@RowDelimeter Varchar(1),@colDelimeter VarChar(1),@valDelimeter VarChar(1) )  
Returns @attributevalueTable Table(attributeid int,attributevalueid int)   
As          
Begin          
insert into @attributevalueTable(attributeid, attributevalueid)    
select distinct id,value derived_value from (                                        
SELECT SUBSTRING(ltrim(rtrim(value)),0,CHARINDEX(@colDelimeter,ltrim(rtrim(value)))) id,                                                              
SUBSTRING(ltrim(rtrim(value)),CHARINDEX(@colDelimeter,ltrim(rtrim(value)))+1,LEN(ltrim(rtrim(value)))) derived_value                                                         
FROM string_split(@inputstring,@RowDelimeter) )c cross apply string_split(derived_value,@valDelimeter)  
Return  
END
GO
