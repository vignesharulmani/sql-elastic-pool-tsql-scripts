/****** Object:  UserDefinedFunction [dbo].[fn_Get_TitleUrl]    Script Date: 10/11/2018 12:16:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fn_Get_TitleUrl]
( @sInput varchar(512), @cReplace char(1) )
returns varchar(max)
BEGIN
Declare @iLen int, @cChar char, @chk int,
@cReplaceMulti varchar(2), @iPos int
Set @iLen = 1
Set @sInput = lower(@sInput);
Set @sInput = ltrim(@sInput);
Set @sInput = rtrim(@sInput);

--Replace all the Special Characters with Given Replace Char...
while ( len(@sInput) >= @iLen )
Begin
	select @chk = 1 WHERE substring(@sInput, @iLen, 1)
	NOT IN ('a','b','c','d','e','f','g','h','i','j','k','l','m',
	'n','o','p','q','r','s','t','u','v','w','x','y','z',
	'0','1','2','3','4','5','6','7','8','9','-')
	if (@chk = 1)
	begin
		set @cChar = substring(@sInput, @iLen, 1)
		set @sInput = replace(@sInput, @cChar, @cReplace)
	end
	set @chk = 0
	set @iLen = @iLen + 1
End

--Replace if in left...
while (left(@sInput,1) = @cReplace)
Begin
	set @sInput = substring(@sInput, 2, len(@sInput))
End
                  
--Replace if in right...
while (right(@sInput,1) = @cReplace)
Begin
	set @sInput = substring(@sInput, 1, len(@sInput)-1)
End

--Replace Multiple @cReplace with Single @cReplace
set @cReplaceMulti = @cReplace + @cReplace
set @iPos = charindex(@cReplaceMulti, @sInput)
while (@iPos > 0)
Begin
	set @sInput = replace(@sInput, @cReplaceMulti, @cReplace)
	set @iPos = charindex(@cReplaceMulti, @sInput)
End

return @sInput
END
GO
