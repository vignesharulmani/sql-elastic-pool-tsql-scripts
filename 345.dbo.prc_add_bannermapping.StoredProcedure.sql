CREATE procedure prc_add_bannermapping
@bannerid bigint
,@adid bigint
,@bannertypeattributevalueid int
,@roundid int = 0
,@isactive int
as
begin

set @roundid = dbo.fn_get_roundid(@bannertypeattributevalueid)

	delete from bannermapping where bannerid = @bannerid

	insert into bannermapping(bannerid,adid,bannertypeattributevalueid,roundid,isactive,crdate)
		values (@bannerid,@adid,@bannertypeattributevalueid,@roundid,@isactive,getdate())


end