Alter function fn_get_roundid(@bannertypeattributevalueid int)
returns int
as
begin

declare @roundid int = 0

if @bannertypeattributevalueid = 973624 /*Titanium*/
	set @roundid = 1
else if @bannertypeattributevalueid = 973625 /*Platinum 1*/
	set @roundid = 2
else if @bannertypeattributevalueid = 973626 /*Platinum 2*/
	set @roundid = 3
else if @bannertypeattributevalueid = 973627 /*Platinum 3*/
	set @roundid = 4
else 
	set @roundid = 0

return(@roundid)

end