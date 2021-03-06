/****** Object:  UserDefinedFunction [dbo].[Split]    Script Date: 10/11/2018 12:16:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[Split]                            
(@ContentIDList varchar(8000),                  
@SplitChar varchar(1))                            
RETURNS @ParsedList Table (items varchar(256), rowid int identity(1,1))                                    
AS                                    
BEGIN                                    
 DECLARE @ContentID varchar(200), @Pos int                                    
                                      
 SET @ContentIDList = LTRIM(RTRIM(@ContentIDList))+ @SplitChar                            
 SET @Pos = CHARINDEX(@SplitChar, @ContentIDList, 1)                                      
                                      
 IF REPLACE(@ContentIDList, @SplitChar, '') <> ''                                      
 BEGIN                                      
  WHILE @Pos > 0                                      
  BEGIN                                      
   SET @ContentID = LTRIM(RTRIM(LEFT(@ContentIDList, @Pos - 1)))                                      
   IF @ContentID <> '' AND @ContentID <> '-'                        
   BEGIN                                      
    INSERT INTO @ParsedList (items)                                       
    VALUES (@ContentID) --Use Appropriate conversion                                      
   END                                      
   SET @ContentIDList = RIGHT(@ContentIDList, LEN(@ContentIDList) - @Pos)                                      
   SET @Pos = CHARINDEX(@SplitChar, @ContentIDList, 1)                                      
                                      
  END                                      
 END                                       
 RETURN                                      
END  
GO
