Alter function fn_calc_runtime_adtype(@admode smallint)
returns varchar(32)
as
begin

declare @returnvalue varchar(32) = ''


if @admode = 110
	set @returnvalue = 'Premium'
else if @admode = 105
	set @returnvalue = 'Priority'
else if @admode = 100
	set @returnvalue = ''/*Free*/
else if @admode = 200
	set @returnvalue = 'Titanium'
else if @admode in (199,198,197)
	set @returnvalue = 'Platinum'
else 
	set @returnvalue = 'Sponsored'

return (@returnvalue)


end