extends Node

onready var audioPlayer = $AudioPlayer

var ambient_music_ini = load("res://Assets/Music/OrbitIni.wav")
var ambient_music_loop = load("res://Assets/Music/OrbitLoop.wav")

func _ready():
	audioPlayer.stream = ambient_music_ini
	audioPlayer.play()

func play_music():
	audioPlayer.stream = ambient_music_loop
	audioPlayer.play()

func _on_AudioPlayer_finished():
	play_music()
