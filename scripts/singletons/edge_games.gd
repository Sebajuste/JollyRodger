extends Node


const UPDATE_TIME := 15




var http_request := HTTPRequest.new()
var timer := Timer.new()

#https://app-3f84a324-4e3c-4d06-97e2-9762c8911708.cleverapps.io/games-lobbies/games/tps/lobbies

var host = "app-3f84a324-4e3c-4d06-97e2-9762c8911708.cleverapps.io"
var port = 443
var use_ssl := true
var protocol := "http" if not use_ssl else "https"


var lobbies := []


# Called when the node enters the scene tree for the first time.
func _ready():
	 
	http_request.connect("request_completed", self, "_on_request_completed")
	add_child(http_request)
	
	
	timer.wait_time = UPDATE_TIME
	timer.connect("timeout", self, "_on_timer_timeout")
	add_child(timer)
	
	
	pass # Replace with function body.


func add_game_info(game_name, instance_name, instance_info):
	instance_info["game_name"] = game_name
	instance_info["instance_name"] = instance_name
	lobbies.append(instance_info)
	timer.start()
	print("game added")


func remove_game_info():
	lobbies.clear()
	timer.stop()
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_timer_timeout():
	print("updating edge game")
	var headers = ["Content-Type: application/json"]
	for instance_info in lobbies:
		
		var query = JSON.print(instance_info)
		
		print("update edge game ", instance_info)
		#var result = http_request.request("http://%s:%d/games-lobbies/games/%s/lobbies/%s" % [instance_info.host, instance_info.port, instance_info.game_name, instance_info.instance_name], headers, use_ssl, HTTPClient.METHOD_PUT, query)
		var result = http_request.request("%s://%s:%d/games-lobbies/games/%s/lobbies/%s" % [protocol, host, port, instance_info.game_name, instance_info.instance_name], headers, use_ssl, HTTPClient.METHOD_PUT, query)
		print("> result : ", result)


func _on_request_completed(result: int, response_code: int, headers: PoolStringArray, body: PoolByteArray):
	
	print("result : ", result)
	print("response_code : ", response_code)
	print("headers : ", headers)
	print("body : ", body.get_string_from_utf8() )
	
	pass
