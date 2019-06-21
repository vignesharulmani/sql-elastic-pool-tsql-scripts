Alter function fn_get_duration(@subcategoryid int,@needid int,@addefid int,@admode smallint)
returns int
as
begin

declare @returnvalue int = 60

select top 1 @returnvalue = duration from dbo.adconfig ac (nolock) 
	where ac.subcategoryid = @subcategoryid
		and ac.needid = @needid
		and ac.addefid = @addefid
		and ac.admode = @admode
		and ac.isactive = 1

if @addefid = 66600
	set @returnvalue = 180

if isnull(nullif(@returnvalue,''),0)=0
	set @returnvalue = 60

	return(@returnvalue)
	
end;