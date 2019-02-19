/****** Object:  StoredProcedure [dbo].[prc_get_adscount]    Script Date: 10/11/2018 12:16:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[prc_get_adscount]    
@cityid int,                          
@areaid int=0,                          
@subcatid int,                          
@addefid int=0,                          
@needid int=0,                          
@needidattributes varchar(250)=''                   
as                      
begin                  
              
set nocount on               
              
declare @needidattribute table(attributeid int, attributevalueid int)                                       
declare @areacount int = 0                      
declare @cnt tinyint=0                                              
declare @AdsCount int = 0                       
declare @cityidtable table(cityid int)                                                
          
if @cityid > 0
begin          
 insert into @cityidtable           
 select @cityid 
end   
            
if @areaid is null                                    
       set @areaid=0                                       
if @needidattributes is null                                              
       set @needidattributes=''                   
              

              
if @needidattributes<>''                                              
begin                                              
       insert into @needidattribute(attributeid,attributevalueid)                                              
       select attributeid, attributevalueid from dbo.SplitAttributes(@needidattributes,',',':',';' )       
    Select @cnt=count(1) from @needidattribute                                              
end                                             
else  
 Set @cnt = 0  
              
                    
              
if @areaid=0 and @areacount=0                                              
Begin                                              
       if (@addefid=0 and @cnt=0)                                              
       Begin                                              
             select @AdsCount =  sum(adscount) from citysubcatadscount(nolock) a                                               
             where a.cityid = @cityid and subcategoryid=@subcatid                                                       
       end                       
              
       if (@addefid>0 and @cnt=0)                                              
       Begin                                       
             select @AdsCount =  sum(adscount) from citysubcatneedadscount(nolock) a                                        
             where  a.cityid = @cityid and subcategoryid=@subcatid and a.addefid=@addefid                                              
       End    
              
       if (@addefid>0 and @cnt>0)                                              
       Begin                                              
			 select @AdsCount = sum(adscount) from citysubcatattributeadscount cs                 
             inner join @needidattribute na on na.attributeid=cs.attributeid and na.attributevalueid=cs.attributevalueid                     
             where cs.cityid = @cityid and cs.subcategoryid=@subcatid                  
       End                                              
              
       if (@subcatid>0 and @addefid=0 and @cnt>0)                                              
       Begin                                              
             select @AdsCount = sum(adscount) from citysubcatattributeadscount cs                 
             inner join @needidattribute na on na.attributeid=cs.attributeid and na.attributevalueid=cs.attributevalueid                 
             where cs.cityid = @cityid and cs.subcategoryid=@subcatid                                              
       End                                              
END               
Else if (@areaid>0 or @areacount>0)                                  
Begin                                              
       if (@addefid=0 and @cnt=0)              
       Begin                   
             select @AdsCount =  adscount from citysubcatareaadscount(nolock) a                                             
             where a.cityid = @cityid and areaid = @areaid and subcategoryid=@subcatid  			               
       end                        
              
       if (@addefid>0 and @cnt=0)                                              
       Begin                                              
             select @AdsCount = adscount from citysubcatneedareaadscount(nolock) a                                               
             where a.cityid = @cityid and areaid=@areaid and subcategoryid=@subcatid and a.addefid=@addefid			                                             
       End                           
              
       if (@addefid>0 and @cnt>0)                                              
       Begin               
             select @AdsCount = max(adscount) from citysubcatareaattributeadscount cs                
             inner join @needidattribute na on na.attributeid=cs.attributeid and na.attributevalueid=cs.attributevalueid                     
             where  cs.cityid = @cityid and areaid=@areaid and cs.subcategoryid=@subcatid 
			 
       End                                              
              
       if (@subcatid>0 and @addefid=0 and @cnt>0)                                              
       Begin                                            
              
             select @AdsCount = max(adscount) from citysubcatareaattributeadscount cs                
             inner join @needidattribute na on na.attributeid=cs.attributeid and na.attributevalueid=cs.attributevalueid                     
             where  cs.cityid = @cityid and areaid=@areaid and cs.subcategoryid=@subcatid
       END                                                                          
end  

select isnull(@AdsCount,0) adcount,1 HasLCF,'' SubCategoryName,0 ParentId,'' ParentCategoryName,'' CategoryGroup
             
end
GO
