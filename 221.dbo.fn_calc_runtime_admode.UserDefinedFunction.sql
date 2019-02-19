CREATE function fn_calc_runtime_admode(@adid bigint)
returns smallint
as
begin

declare @roundid int = 0,
@admode smallint=0

select @roundid = roundid from bannermapping bm (nolock) where adid = @adid 
and bannertypeattributevalueid in (973624,973625,973626,973627)
and isactive = 1

if @roundid = 1
	set @admode = 200
else if @roundid = 2
	set @admode = 199
else if @roundid = 3
	set @admode = 198
else if @roundid = 4
	set @admode = 197

return (@admode)

end