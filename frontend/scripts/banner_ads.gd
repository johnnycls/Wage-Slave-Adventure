extends Control

var _ad_view : AdView
var unit_id : String

func _ready():
	if OS.get_name() == "Android":
		unit_id = Global.android_banner_unit_id
	elif OS.get_name() == "iOS":
		unit_id = Global.ios_banner_unit_id
		
	if _ad_view == null:
		create_ad_view()

func create_ad_view() -> void:
	if not _ad_view:
		_ad_view = AdView.new(unit_id, AdSize.BANNER, AdPosition.Values.BOTTOM)
		var ad_request := AdRequest.new()
		_ad_view.load_ad(ad_request)

func destroy_ad_view() -> void:
	if _ad_view:
		_ad_view.destroy()
		_ad_view = null
