extends CharacterBody2D

@export var tile_map : TileMapLayer 
@export var move_duration: float = 0.2

var is_moving: bool = false
var current_grid_pos: Vector2i

func _ready():
	# 初始化：對齊網格
	global_position = tile_map.map_to_local(current_grid_pos)
	current_grid_pos = tile_map.local_to_map(global_position)
	

func _unhandled_input(event):
	if is_moving: return
	
	if event is InputEventMouseButton and event.is_pressed():
		# 1. 取得點擊的網格座標 (簡化寫法)
		var target_pos = tile_map.local_to_map(tile_map.get_local_mouse_position()) 
		
		# 2. 檢查是否為鄰居且真的有地圖圖塊
		if _is_valid_move(target_pos):
			move_to_grid(target_pos)

# 判斷邏輯獨立出來
func _is_valid_move(target: Vector2i) -> bool:
	var neighbors = tile_map.get_surrounding_cells(current_grid_pos) 
	var has_tile = tile_map.get_cell_source_id(target) != -1 # 確保點的地方有格子
	return target in neighbors and has_tile

func move_to_grid(target_grid_pos: Vector2i):
	is_moving = true
	current_grid_pos = target_grid_pos
	
	var tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	# 直接移動到目標位置 
	tween.tween_property(self, "global_position", tile_map.map_to_local(target_grid_pos), move_duration)
	tween.tween_callback(func(): is_moving = false)
