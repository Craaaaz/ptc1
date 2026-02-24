extends CharacterBody2D

# [依賴]
# 在編輯器裡，把你的 TileMapLayer 節點拖進這個欄位
@export var tile_map: TileMapLayer

# [設定]
@export var move_duration: float = 0.2

# [狀態]
var is_moving: bool = false
var current_grid_pos: Vector2i

func _ready():
	# 確保 TileMap 有被設定
	if not tile_map:
		printerr("錯誤：請在 Player 的屬性面板中指定 TileMapLayer！")
		set_physics_process(false)
		return

	# 1. 初始定位：直接用現在的像素位置反推網格座標
	# local_to_map 是 TileMapLayer 的神技
	current_grid_pos = tile_map.local_to_map(position)
	
	# 2. 修正位置：確保角色站在格子正中心
	position = tile_map.map_to_local(current_grid_pos)

func _unhandled_input(event):
	# 1. 如果正在移動，無視輸入
	if is_moving:
		return
	
	# 2. 偵測滑鼠左鍵點擊
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		handle_click(event.position)

func handle_click(mouse_pos: Vector2):
	# [核心邏輯]
	# 1. 算出滑鼠點到了哪一格？(因為 Player 可能有父節點偏移，建議用 global_mouse_position)
	var global_mouse_pos = get_global_mouse_position()
	# 將全域滑鼠座標轉為 TileMap 的本地座標，再轉為網格座標
	var clicked_cell_pos = tile_map.local_to_map(tile_map.to_local(global_mouse_pos))
	
	# 2. 判斷：點到的是不是「鄰居」？
	# get_surrounding_cells 會回傳周圍所有格子的座標陣列
	var neighbors = tile_map.get_surrounding_cells(current_grid_pos)
	
	# 3. 如果點擊的格子在鄰居列表裡，就移動
	if clicked_cell_pos in neighbors:
		move_to_grid(clicked_cell_pos)
	else:
		print("太遠了，走不到！點擊: ", clicked_cell_pos, " 目前: ", current_grid_pos)

func move_to_grid(target_grid_pos: Vector2i):
	is_moving = true
	
	# 更新網格座標
	current_grid_pos = target_grid_pos
	
	# 算出世界座標 (像素)
	var target_world_pos = tile_map.map_to_local(target_grid_pos)
	
	# Tween 動畫 (這部分跟之前一樣)
	var tween = create_tween()
	tween.tween_property(self, "position", target_world_pos, move_duration) \
		.set_trans(Tween.TRANS_SINE) \
		.set_ease(Tween.EASE_OUT)
	
	tween.tween_callback(func(): is_moving = false)
