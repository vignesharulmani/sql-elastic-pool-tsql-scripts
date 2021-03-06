create function fn_merge_attributevalues(@addefid int,@needidattribute split_needidattribute readonly)
returns @output table (attributeid int,attributevalueid int)
as
begin

if @addefid = 59500
begin
/*For 1 BHK also include 2,3,4,4+ BHK*/
if exists (select top 1 1 from @needidattribute where attributeid = 256207 and attributevalueid = 969734)
	insert into @output(attributeid,attributevalueid)
		values (256207,969735),(256207,969736),(256207,969737),(256207,969738)
/*For 2 BHK also include 3,4,4+ BHK*/
else if exists (select top 1 1 from @needidattribute where attributeid = 256207 and attributevalueid = 969735)
	insert into @output(attributeid,attributevalueid)
		values (256207,969736),(256207,969737),(256207,969738)
/*For 3 BHK also include 4,4+ BHK*/
else if exists (select top 1 1 from @needidattribute where attributeid = 256207 and attributevalueid = 969736)
	insert into @output(attributeid,attributevalueid)
		values (256207,969737),(256207,969738)
/*For 4 BHK also include 4+ BHK*/
else if exists (select top 1 1 from @needidattribute where attributeid = 256207 and attributevalueid = 969736)
	insert into @output(attributeid,attributevalueid)
		values (256207,969738)
end

insert into @output(attributeid,attributevalueid)
	select 	attributeid,attributevalueid from @needidattribute

return

end