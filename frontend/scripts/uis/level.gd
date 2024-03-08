extends ScrollContainer

func init(data):
	$PopupPanel.hide()
	for level in data: 
		var button = Button.new()
		button.text = level.label if level.key <= Global.unlocked_progress else tr("LOCKED")
		button.pressed.connect(func():
			if level.key <= Global.unlocked_progress:
				level.on_pressed.call()
			else:
				$PopupPanel/Label.text = level.condition
				$PopupPanel.show())
		$HBoxContainer.add_child(button)
