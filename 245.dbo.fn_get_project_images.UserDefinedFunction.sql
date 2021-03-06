CREATE FUNCTION fn_get_project_images(@adid BIGINT)
RETURNS @outputtable TABLE(adid bigint,mediaurl varchar(256),mediacaption varchar(256),attributeid int)
AS
BEGIN


	INSERT INTO @outputtable(adid,mediaurl,mediacaption,attributeid)
	SELECT	m.adid,m.mediaurl,m.mediacaption TagName,m.attributeid
	FROM	dbo.adsmedia m(NOLOCK)
	WHERE	m.adid = @adid
	and m.attributeid = 299700 /*Project Images*/

	RETURN;

END
