Alter function fn_get_projecturl(@buildingname varchar(128),@areaname varchar(64),@cityname varchar(64)
									,@projectid bigint,@businessid int)
returns varchar(512)
as
begin

declare @returnvalue varchar(512)=''
declare @isbroker int = 0
declare @businesstitleurl varchar(128)=''

if @projectid > 0 and @businessid > 0
begin

if (@buildingname = '' or @areaname= '' or @cityname = '') 
	select top 1 @buildingname = adtitle, @areaname = areaname,@cityname = cityname
	from dbo.adsmaster am (nolock) where am.adid = @projectid

set @returnvalue = '/' + dbo.fn_get_titleurl(@buildingname,'-') + '-in-' + dbo.fn_get_titleurl(@areaname,'-')
						+ '-' + dbo.fn_get_titleurl(@cityname,'-') 

select top 1 @isbroker = 1, @businesstitleurl = businesstitleurl 
from dbo.projectbusinessmapping pbm (nolock) 
where pbm.status = 1 and pbm.customertype not in (1036002,1036102) /*Exclude Builder/Plot Promoter*/
and pbm.projectid = @projectid and pbm.businessid = @businessid

if isnull(@isbroker,0) = 1
	set @returnvalue  = @returnvalue + '-by-' + @businesstitleurl

set @returnvalue = @returnvalue+'-'+convert(varchar,@projectid)+'-pd'

end

return (@returnvalue)

end