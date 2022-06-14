extends Node

onready var audioPlayer = $AudioPlayer

var ambient_music = load("")

func _ready():
	play_music()

func play_music():
	audioPlayer.stream = ambient_music
	audioPlayer.play()

func _on_AudioPlayer_finished():
	play_music()
