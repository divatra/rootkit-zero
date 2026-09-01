extends CenterContainer


onready var buttons = [
	$Menu/Button1,
	$Menu/Button2,
	$Menu/Button3,
	$Menu/Button4
]

# Store base text titles matching button index
var original_labels = [
	"PLAY CAMPAIGN",
	"SETTINGS",
	"HELP & INFO",
	"TERMINATE"
]

func _ready():
	for i in range(buttons.size()):
		var btn = buttons[i]
		var label_text = original_labels[i]
		
		# Set baseline text
		btn.text = label_text
		
		# Bind mouse enter/exit signals with button index
		btn.connect("mouse_entered", self, "_on_button_hover", [btn, label_text])
		btn.connect("mouse_exited", self, "_on_button_unhover", [btn, label_text])

func _on_button_hover(btn: Button, base_text: String):
	btn.text = "> " + base_text + " <"

func _on_button_unhover(btn: Button, base_text: String):
	btn.text = base_text
