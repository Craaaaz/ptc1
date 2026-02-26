extends Area2D

# 定義一個信號，當士兵被點擊時發出通知
signal unit_clicked(me)
signal movement_finished(unit) # 新增：當走完所有路徑時通知主場景

# 記錄士兵目前的格子座標
var grid_pos: Vector2i
var is_moving: bool = false # 防止移動中被重複點擊或再次移動

# 屬性設定
@export var move_speed: float = 0.25 # 每走一格需要幾秒

func _ready():
	input_event.connect(_on_input_event)

# 處理點擊事件
func _on_input_event(_viewport, event, _shape_idx):
	if is_moving:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		unit_clicked.emit(self)

# 移動函數(new)
func walk_along_path(path_world_points: Array[Vector2], final_grid_pos: Vector2i):
	if path_world_points.is_empty():
		return
	
	is_moving = true
	
	# 建立一個 Tween 動畫
	var tween = create_tween()
	for point in path_world_points:
		tween.tween_property(self, "position", point, move_speed).set_trans(Tween.TRANS_LINEAR)# tween_property 預設是序列執行的 (一個做完才做下一個)
		# (選用) 如果想要每走一步頓一下，可以加一點延遲
		# tween.tween_interval(0.05)
	await tween.finished
	
	# 移動結束後的處理
	grid_pos = final_grid_pos # 更新內部紀錄的網格座標
	is_moving = false
	movement_finished.emit(self) # 通知主場景「我走到了」

# 初始化位置用 (瞬間移動)
func set_grid_position(new_grid_pos: Vector2i, new_world_pos: Vector2):
	grid_pos = new_grid_pos
	position = new_world_pos
