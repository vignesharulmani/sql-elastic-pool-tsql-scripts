CREATE function fn_get_projectbusinessmapping_businesstitleurl(@projectid bigint,@businesstitleurl varchar(128))
returns @outputtable table (mapid int,projectid bigint,businessid int
							,minprice money,maxprice money
							,minarea int,maxarea int
							,displaybedroom varchar(64)
							,customertypevalueid int)
as
begin

declare @lv_businesstitleurl varchar(128) = isnull(@businesstitleurl,'')

insert into @outputtable(mapid,projectid,businessid,minprice,maxprice,minarea,maxarea
							,displaybedroom,customertypevalueid)
SELECT TOP 1  
 pbm.rowid,pbm.projectid,pbm.businessid,pbm.minprice,pbm.maxprice,  
 pbm.minareavalue minarea,pbm.maxareavalue maxarea,
 pbm.displaybedroom,pbm.customertype  customertypevalueid
 FROM dbo.projectbusinessmapping pbm (NOLOCK)   
 WHERE pbm.projectid = @projectid  
 and (pbm.businesstitleurl = @lv_businesstitleurl or (@lv_businesstitleurl='' and pbm.customertype = 1036002))
 and pbm.status = 1

 return

 end