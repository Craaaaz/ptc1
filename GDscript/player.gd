extends CharacterBody2D

@export var tile_map : TileMapLayer 
@export var move_duration: float = 0.2
@export var range : int
@onready var coord_label = get_node("../CanvasLayer/Control/Label") #右下角標籤

var is_moving = false # 記錄角色是否正在移動
var is_selected: bool = false # 記錄角色是否被選中
@export var current_grid_pos : Vector2i 

func _ready():	#當執行按下時
	global_position = tile_map.map_to_local(current_grid_pos)
	current_grid_pos = tile_map.local_to_map(global_position)
	
#var target_pos = tile_map.local_to_map(tile_map.get_local_mouse_position()) #target = 目標 pos = 位置	
func _unhandled_input(event: InputEvent) -> void:
	if is_moving: return 
	
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var global_mouse_pos = get_global_mouse_position()
		var target_pos = tile_map.local_to_map(tile_map.to_local(global_mouse_pos)) #target = 目標 pos = 位置

		# 顯示點擊資訊
		coord_label.text = "當前座標: " + str(target_pos)

		# 檢查是否點擊在角色所在的格子上 (用來「選取」角色)
		if target_pos == current_grid_pos:
			is_selected = !is_selected # 切換選取狀態

			if is_selected:
				print("角色已選取！請點擊目的地。")

				scale = Vector2(1.2, 1.2) 

			else:
				print("取消選取。")
				scale = Vector2(1.0, 1.0)
			return # 點擊角色後就結束，不執行後續移動判斷

		# 如果角色已經被選取，才執行移動判斷
		if is_selected:
			if is_valid_move(target_pos):
				move_step_by_step(target_pos) 
				# 移動開始後，重置選取狀態
				is_selected = false
				scale = Vector2(1.0, 1.0)
			else:
				print("無效移動：超出範圍或目標點不合法。")
				is_selected = false
				scale = Vector2(1.0, 1.0)


func _to_axial(map_pos: Vector2i) -> Vector2i:
	var q = map_pos.x - (map_pos.y - (map_pos.y & 1)) / 2
	var r = map_pos.y
	return Vector2i(q, r)

func calculate_distance(target_pos: Vector2i) -> bool: #calculate = 計算 distance = 距離
	
	var current_axial = _to_axial(current_grid_pos)
	var target_axial = _to_axial(target_pos)
	
	
	var dq = current_axial.x - target_axial.x
	var dr = current_axial.y - target_axial.y
	var hex_dist = (abs(dq) + abs(dr) + abs(dq + dr)) / 2
	
	return hex_dist <= range

func is_valid_move(target_pos) -> bool:
	var neighbors = calculate_distance(target_pos)
	var has_tile = tile_map.get_cell_source_id(target_pos) != -1 # 確保點的地方有格子
	return has_tile and neighbors 
	
func move_to_grid(target_pos) -> void:
	is_moving = true
	current_grid_pos = target_pos
	var tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	
	tween.tween_property(self, "global_position", tile_map.map_to_local(target_pos), move_duration)
	tween.tween_callback(func(): is_moving = false)
	
func move_step_by_step(target_grid) -> void:
	is_moving = true
	
	var path = calculate_hex_path(current_grid_pos, target_grid)
	
	# 2. 依照路徑順序移動 
	for next_pos in path:
		if next_pos == current_grid_pos: continue # 跳過起點 [cite: 1]
		
		# 建立移動動畫 
		var tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		var pixel_pos = tile_map.map_to_local(next_pos)
		
		tween.tween_property(self, "global_position", pixel_pos, move_duration)
		
		# 關鍵：等待動畫完成才繼續下一圈迴圈 
		await tween.finished
		
		# 更新當前邏輯座標 [cite: 1]
		current_grid_pos = next_pos
		coord_label.text = "移動中: " + str(current_grid_pos)

	is_moving = false
	print("到達目的地！") 

# 計算六邊形路徑
func calculate_hex_path(start: Vector2i, end: Vector2i) -> Array:
	var path = []
	var current = start
	path.append(current)

	while current != end:
		var neighbors = tile_map.get_surrounding_cells(current) # 取得周圍 6 格 
		var best_neighbor = current
		var min_dist = 9999

		for n in neighbors:
			# 計算是否靠近
			var d = _get_hex_distance(n, end)
			if d < min_dist:
				min_dist = d
				best_neighbor = n

		current = best_neighbor
		path.append(current)

		if path.size() > 20: break 

	return path


func _get_hex_distance(a: Vector2i, b: Vector2i) -> int:
	var aq = _to_axial(a)
	var bq = _to_axial(b)
	return (abs(aq.x - bq.x) + abs(aq.y - bq.y) + abs(aq.x + aq.y - bq.x - bq.y)) / 2 
	
	
	
	
	
	
	
