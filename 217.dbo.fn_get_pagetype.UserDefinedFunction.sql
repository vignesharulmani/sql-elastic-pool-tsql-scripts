/****** Object:  UserDefinedFunction [dbo].[fn_get_pagetype]    Script Date: 10/11/2018 12:16:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create function fn_get_pagetype(@categoryid int)
returns varchar(64)
as
begin
	return(iif(@categoryid=201,'AdPost','OfferPost'))
end
GO
