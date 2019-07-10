Alter function fn_get_projectbusinessmapping(@projectid bigint,@businessid int)
returns @outputtable table (mapid int,projectid bigint,businessid int
							,minprice money,maxprice money
							,minarea int,maxarea int
							,displaybedroom varchar(64)
							,customertypevalueid int)
as
begin

insert into @outputtable(mapid,projectid,businessid,minprice,maxprice,minarea,maxarea
							,displaybedroom,customertypevalueid)
SELECT TOP 1  
 pbm.rowid,pbm.projectid,pbm.businessid,pbm.minprice,pbm.maxprice,  
 pbm.minareavalue minarea,pbm.maxareavalue maxarea,
 pbm.displaybedroom,pbm.customertype  customertypevalueid
 FROM dbo.projectbusinessmapping pbm (NOLOCK)   
 WHERE pbm.projectid = @projectid  
 and pbm.businessid = @businessid 
 and pbm.status = 1

 return

 end