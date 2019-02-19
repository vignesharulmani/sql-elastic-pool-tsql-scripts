Alter function fn_get_adclassification(@PageType VARCHAR(32))
returns int
as
begin

declare @AdClassification int = 0

 if @PageType = 'FPS'
	set @AdClassification = 1
else if @PageType = 'OfferPost'
	set @AdClassification = 2
else if @PageType = 'AdPost'
	set @AdClassification = 3
else if @PageType = 'Banners'
	set @AdClassification = 4

return(@AdClassification)

end