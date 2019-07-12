Alter function fn_get_projecturl(@buildingname varchar(128),@areaname varchar(64),@cityname varchar(64)
									,@projectid bigint,@businessid int)
returns varchar(512)
as
begin

declare @returnvalue varchar(512)=''
declare @isbroker int = 0
declare @businesstitleurl varchar(128)=''

set @returnvalue = '/' + dbo.fn_get_titleurl(@buildingname,'-') + '-in-' + dbo.fn_get_titleurl(@areaname,'-')
						+ '-' + dbo.fn_get_titleurl(@cityname,'-') 

select top 1 @isbroker = 1, @businesstitleurl = businesstitleurl 
from dbo.projectbusinessmapping pbm (nolock) 
where pbm.status = 1 and pbm.customertype <> 1036002
and pbm.projectid = @projectid and pbm.businessid = @businessid

if isnull(@isbroker,0) = 1
	set @returnvalue  = @returnvalue + '-by-' + @businesstitleurl

return (@returnvalue+'-'+convert(varchar,@projectid)+'-pd')

end