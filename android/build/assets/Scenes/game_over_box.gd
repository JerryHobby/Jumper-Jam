extends TextureRect

@onready var score_label = $ScoreLabel
@onready var high_score_label = $HighScoreLabel

# Called when the node enters the scene tree for the first time.
func _ready():
	GameManager.onGameOver.connect(onGameOver)


func onGameOver():
	score_label.text = "Score: %d" % GameManager.get_score()
	high_score_label.text = "Best: %d" % GameManager.get_high_score()
