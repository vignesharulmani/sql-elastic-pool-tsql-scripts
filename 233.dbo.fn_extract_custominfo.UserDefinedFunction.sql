Alter function fn_extract_custominfo(@custominfo nvarchar(max),@attributename nvarchar(64))
returns nvarchar(128)
as
begin

declare @outputvalue nvarchar(128)=''

select @outputvalue = json_value(json_query(value,'$.UserNeedAttributeValues[0]'),'$.AttributeValue')
from openjson(@custominfo) 
where json_value(value,'$.AttributeName')=@attributename
and isjson(@custominfo)=1

return(@outputvalue)

end