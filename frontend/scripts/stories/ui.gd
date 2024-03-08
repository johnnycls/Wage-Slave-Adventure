extends VBoxContainer

func init(skip_func):
	$Button.pressed.connect(skip_func)

func change_text(text):
	if (text==""): 
		$CenterContainer.hide() 
	else:
		$CenterContainer/Label.text = text
		$CenterContainer.show()
