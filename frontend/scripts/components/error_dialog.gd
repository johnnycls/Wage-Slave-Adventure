extends PopupPanel

func init(title, label, close_event):
	title = title  
	$Label.text = label
	$Button.pressed.connect(close_event)
	popup_hide.connect(close_event)
