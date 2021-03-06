CREATE function dbo.fn_tosqft(@areaofsqft float,@unit varchar(25))                            
returns bigint  
as                            
begin                            
declare @ReturnArea as bigint                
         
 select @ReturnArea =                             
 case                             
 when @unit = 'acres' then (@areaofsqft*43560)      
 when @unit = 'grounds' then (@areaofsqft*2400)      
 when @unit = 'hectares' then (@areaofsqft*107639.10)      
 when @unit = 'sq feet' then (@areaofsqft*1)      
 when @unit = 'sq meters' then (@areaofsqft*10.76)      
 when @unit = 'sq yards' then (@areaofsqft*9)                             
 when @unit = 'cents' then (@areaofsqft*435.60)
 /* Refer : https://www.easycalculation.com/unit-conversion/Acres-acres-Square_Feet-sq_ft.html */      
 when @unit = 'aankadam' then (@areaofsqft*71.99)
 when @unit = 'perch' then (@areaofsqft*272.3)
 when @unit = 'rood' then (@areaofsqft*10893.24)
 when @unit = 'chataks' then (@areaofsqft*450.0)
 when @unit = 'ares' then (@areaofsqft*1076.07)
 when @unit = 'biswa' then (@areaofsqft*357142.85)
 when @unit = 'bigha' then (@areaofsqft*17452)
 when @unit = 'kottah' then (@areaofsqft*720.04)
 when @unit = 'kanal' then (@areaofsqft*5399.56)
 when @unit = 'marla' then (@areaofsqft*272.251)
 else @areaofsqft/1                            
                        
end            
return @ReturnArea                           
end