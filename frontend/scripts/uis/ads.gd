extends Button

var rewarded_ad : RewardedAd
var on_user_earned_reward_listener := OnUserEarnedRewardListener.new()
var rewarded_ad_load_callback := RewardedAdLoadCallback.new()
var full_screen_content_callback := FullScreenContentCallback.new()
var unit_id: String

func on_rewarded_ad_failed_to_load(adError : LoadAdError) -> void:
	$Loading.hide()
	disabled = false
	$"../../../HBoxContainer/Button".disabled = false
	print(adError.message)
	
func on_rewarded_ad_loaded(_rewarded_ad : RewardedAd) -> void:
	print("rewarded ad loaded" + str(rewarded_ad._uid))
	_rewarded_ad.full_screen_content_callback = full_screen_content_callback

	var server_side_verification_options := ServerSideVerificationOptions.new()
	server_side_verification_options.user_id = Global.user_id
	_rewarded_ad.set_server_side_verification_options(server_side_verification_options)

	rewarded_ad = _rewarded_ad
	
	if rewarded_ad:
		rewarded_ad.show(on_user_earned_reward_listener)

func _ready():		
	if OS.get_name() == "Android":
		unit_id = Global.android_unit_id
	elif OS.get_name() == "iOS":
		unit_id = Global.ios_unit_id
		
	on_user_earned_reward_listener.on_user_earned_reward = on_user_earned_reward
	
	rewarded_ad_load_callback.on_ad_failed_to_load = on_rewarded_ad_failed_to_load
	rewarded_ad_load_callback.on_ad_loaded = on_rewarded_ad_loaded

	full_screen_content_callback.on_ad_clicked = func() -> void:
		print("on_ad_clicked")
	full_screen_content_callback.on_ad_dismissed_full_screen_content = func() -> void:
		print("on_ad_dismissed_full_screen_content")
		destroy()
		
	full_screen_content_callback.on_ad_failed_to_show_full_screen_content = func(ad_error : AdError) -> void:
		print("on_ad_failed_to_show_full_screen_content")
	full_screen_content_callback.on_ad_impression = func() -> void:
		print("on_ad_impression")
	full_screen_content_callback.on_ad_showed_full_screen_content = func() -> void:
		print("on_ad_showed_full_screen_content")

func _on_button_pressed():
	disabled = true
	$"../../../HBoxContainer/Button".disabled = true
	$Loading.show()
	RewardedAdLoader.new().load(unit_id, AdRequest.new(), rewarded_ad_load_callback)

func on_user_earned_reward(rewarded_item : RewardedItem):
	destroy()
	Global.money += 1000
	Global.highest_money = max(Global.money, Global.highest_money)
	$"../../../HBoxContainer/Label".text = "$" + str(Global.money/100)

func destroy():
	disabled = false
	$"../../../HBoxContainer/Button".disabled = false
	$Loading.hide()
	if rewarded_ad:
		rewarded_ad.destroy()
		rewarded_ad = null 
