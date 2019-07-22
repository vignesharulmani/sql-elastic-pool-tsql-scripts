Alter function fn_get_projectbusinessmapping_businesstitleurl(@projectid bigint,@businesstitleurl varchar(128))
returns @outputtable table (mapid int,projectid bigint,businessid int
							,customerid int,campaignid int
							,minprice money,maxprice money
							,minarea int,maxarea int
							,displaybedroom varchar(64)
							,customertypevalueid int
							,contactname varchar(128)
							,emailid varchar(128)
							,mobileno varchar(16)
							,businessname varchar(128)
							,businesstitleurl varchar(128)
							,businessurl varchar(128))
as
begin

declare @lv_businesstitleurl varchar(128) = isnull(@businesstitleurl,'')

insert into @outputtable(mapid,projectid,businessid,customerid,campaignid,minprice,maxprice,minarea,maxarea
							,displaybedroom,customertypevalueid,contactname,emailid,mobileno
							,businessname,businesstitleurl,businessurl)
SELECT TOP 1  
 pbm.rowid,pbm.projectid,pbm.businessid,pbm.customerid,pbm.campaignid,pbm.minprice,pbm.maxprice,  
 pbm.minareavalue minarea,pbm.maxareavalue maxarea,
 pbm.displaybedroom,pbm.customertype  customertypevalueid,
 pbm.contactname,pbm.emailid,pbm.mobileno,
 pbm.businessname,pbm.businesstitleurl,pbm.businessurl
 FROM dbo.projectbusinessmapping pbm (NOLOCK)   
 WHERE pbm.projectid = @projectid  
 and (pbm.businesstitleurl = @lv_businesstitleurl or (@lv_businesstitleurl='' and pbm.customertype = 1036002))
 and pbm.status = 1

 return

 end