extends CanvasLayer

onready var enterBoardLoading = get_parent().get_node("EnterBoard/Margin/Loading")
onready var enterBoardVbox = get_parent().get_node("EnterBoard/Margin/VBox")
onready var enterBoardName: LineEdit = get_parent().get_node("EnterBoard/Margin/VBox/PlayerName")
onready var sendBtn = get_parent().get_node("EnterBoard/Margin/VBox/SendScore")

onready var rankLoading = get_parent().get_node("YourRank/Margin/Loading")
onready var rankBoard = get_parent().get_node("YourRank/Margin/Grid")

onready var boardLoading = get_parent().get_node("HighScore/Margin/Loading")
onready var board = get_parent().get_node("HighScore/Margin/Top10")

var request = false
var sendName = false
var sendScore = false
var getLeaderboard = false
var getRank = false

var sendBtnDisabled = true
var token = ""
var playerName = ""
var playerRank = 0

func _ready():
	if GlobalSettings.playerName != "":
		playerName = GlobalSettings.playerName
		enterBoardName.set_text(playerName)
	if GlobalSettings.token != "":
		token = GlobalSettings.token
		get_leaderboard()
	else:
		send_request()

func send_request():
	request = true
	var url = "https://api.lootlocker.io/game/v2/session/guest"
	var _custom_headers: PoolStringArray
	_custom_headers.append("Content-Type: application/json")
	var body = "{\"game_key\": \"ec3e1e2b700e0e511e20712c33c13a2d508a12ff\", \"game_version\": \"0.10.0.0\", \"development_mode\": \"false\"}"
	$HTTPRequest.request(url, _custom_headers, true, HTTPClient.METHOD_POST, body)
	# Error request(url: String, _custom_headers: PoolStringArray = PoolStringArray(  ),
	# ssl_validate_domain: bool = true, method: Method = 0, request_data: String = "")

func send_name():
	sendName = true
	rankBoard.set_visible(false)
	var url = "https://api.lootlocker.io/game/player/name"
	var _custom_headers: PoolStringArray
	_custom_headers.append("LL-Version: 2021-03-01")
	_custom_headers.append("Content-Type: application/json")
	_custom_headers.append(str("x-session-token: ", token))
	var body = str("{\"name\": \"", playerName, "\"}")
	$HTTPRequest.request(url, _custom_headers, true, HTTPClient.METHOD_PATCH, body)

func send_score(score: int):
	sendScore = true
	var url = "https://api.lootlocker.io/game/leaderboards/3789/submit"
	var _custom_headers: PoolStringArray
	_custom_headers.append("Content-Type: application/json")
	_custom_headers.append(str("x-session-token: ", token))
	var body = str("{\"score\": ", score, "}")
	$HTTPRequest.request(url, _custom_headers, true, HTTPClient.METHOD_POST, body)

func get_leaderboard():
	getLeaderboard = true
	board.set_visible(false)
	boardLoading.set_visible(true)
	for n in board.get_children():
		board.remove_child(n)
		n.queue_free()
	var url = "https://api.lootlocker.io/game/leaderboards/3789/list?count=10"
	var _custom_headers: PoolStringArray
	_custom_headers.append("Content-Type: application/json")
	_custom_headers.append(str("x-session-token: ", token))
	$HTTPRequest.request(url, _custom_headers, true, HTTPClient.METHOD_GET)

func get_rank():
	if playerRank > 10:
		getRank = true
		rankLoading.set_visible(true)
		var rankRange = str(playerRank - 3)
		var url = str("https://api.lootlocker.io/game/leaderboards/3789/list?count=5&after=", rankRange)
		var _custom_headers: PoolStringArray
		_custom_headers.append("Content-Type: application/json")
		_custom_headers.append(str("x-session-token: ", token))
		$HTTPRequest.request(url, _custom_headers, true, HTTPClient.METHOD_GET)
	else:
		get_leaderboard()

func _on_request_completed(_result, _response_code, _headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	if request:
		request = false
		token = json.result.session_token
		GlobalSettings.token = token
		get_leaderboard()
	elif getLeaderboard:
		getLeaderboard = false
		fill_top10(json)
	elif sendName:
		sendName = false
		send_score(GlobalSettings.score)
	elif sendScore:
		sendScore = false
		enterBoardLoading.set_visible(false)
		playerRank = json.result.rank
		get_rank()
	elif getRank:
		getRank = false
		fill_your_rank(json)
		get_leaderboard()

func _on_PlayerName_text_changed(new_text):
	playerName = new_text

func _on_SendScore_button_up():
	enterBoardVbox.set_visible(false)
	enterBoardLoading.set_visible(true)
	GlobalSettings.playerName = playerName
	send_name()

func fill_top10(json):
	var lbl1 = Label.new()
	lbl1.set_h_size_flags(Control.SIZE_EXPAND_FILL)
	lbl1.set_align(Label.ALIGN_CENTER)
	lbl1.set_text("TOP10:")
	board.add_child(lbl1)
	var lbl2 = Label.new()
	lbl2.set_h_size_flags(Control.SIZE_SHRINK_END)
	lbl2.set_text("")
	board.add_child(lbl2)
	for keys in json.result.items:
		var label1 = Label.new()
		label1.set_h_size_flags(Control.SIZE_EXPAND_FILL)
		label1.set_text(str(keys.rank, ": ", keys.player.name))
		board.add_child(label1)
		var label2 = Label.new()
		label2.set_h_size_flags(Control.SIZE_EXPAND_FILL)
		label2.set_text(str(" ??? ", keys.score))
		board.add_child(label2)
	boardLoading.set_visible(false)
	board.set_visible(true)
	if sendBtnDisabled:
		sendBtnDisabled = false
		sendBtn.set_disabled(false)

func fill_your_rank(json):
	var lbl1 = Label.new()
	lbl1.set_h_size_flags(Control.SIZE_EXPAND_FILL)
	lbl1.set_align(Label.ALIGN_CENTER)
	lbl1.set_text(tr("POSITION"))
	rankBoard.add_child(lbl1)
	var lbl2 = Label.new()
	lbl2.set_h_size_flags(Control.SIZE_SHRINK_END)
	lbl2.set_text("")
	rankBoard.add_child(lbl2)
	for keys in json.result.items:
		var label1 = Label.new()
		label1.set_h_size_flags(Control.SIZE_EXPAND_FILL)
		label1.set_text(str(keys.rank, ": ", keys.player.name))
		rankBoard.add_child(label1)
		var label2 = Label.new()
		label2.set_h_size_flags(Control.SIZE_EXPAND_FILL)
		label2.set_text(str(" ??? ", keys.score))
		rankBoard.add_child(label2)
	rankLoading.set_visible(false)
	rankBoard.set_visible(true)
