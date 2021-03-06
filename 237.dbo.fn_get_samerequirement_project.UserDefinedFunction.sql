Alter function fn_get_samerequirement_project
( @cityid int,  @areaid int, @projectname varchar(128),@projectid bigint)
returns int
as 
begin 
	Declare @returnvalue bigint 

		select top 1 @returnvalue = a.adid from adsmaster(nolock) a
		join adsneedmapping(nolock) b on a.adid = b.adid
		where b.adid > 0 
		and b.adid <> @projectid
		and b.cityid = @cityid 
		and b.areaid = @areaid
		and b.subcategoryid > 0
		and b.needid > 0
		and b.addefid > 0
		and b.adclassification = 7
		and a.adtitle = @projectname
		and a.status = 1		

return @returnvalue

end