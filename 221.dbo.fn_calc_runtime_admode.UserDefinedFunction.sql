Alter function fn_calc_runtime_admode(@adid bigint)
returns smallint
as
begin

declare @roundid int = 0,
@admode smallint=0

select @roundid = bm.roundid from bannermapping bm (nolock) where bm.adid = @adid 
and exists (select top 1 1 from attributevaluepriority avp (nolock) 
		where avp.attributevalueid = bm.bannertypeattributevalueid and avp.isactive = 1)
and bm.isactive = 1

if @roundid = 1
	set @admode = 200 /*Titanium*/
else if @roundid = 2
	set @admode = 199 /*Platinum 1*/
else if @roundid = 3
	set @admode = 198 /*Platinum 2*/
else if @roundid = 4
	set @admode = 197 /*Platinum 3*/

return (@admode)

end