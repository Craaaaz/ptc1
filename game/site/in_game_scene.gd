extends Node2D

# 預先載入國王的場景檔案
var king_scene = preload("res://game/unit/king.tscn")

# 取得那個用來裝國王的容器節點
@onready var units_container = $Units
@onready var map = $MapSetup

var selected_unit = null
var occupied_cells = {}

var astar = AStar2D.new()
var cell_to_id = {} # 記錄 [網格座標] 對應到 [A* ID]
var next_point_id = 0

func _ready():
	setup_navigation_grid()
	
	spawn_king(Vector2i(2, 2))
	spawn_king(Vector2i(5, 3))

func setup_navigation_grid():
	astar.clear()
	cell_to_id.clear()
	next_point_id = 0
	# 把所有「非障礙物」的地板加入 A* 系統
	for cell in map.get_used_cells():
		var _source_id = map.get_cell_source_id(cell) #用來排除障礙物，例如：山地
		#if source_id == 1:
		#	continue 
		
		cell_to_id[cell] = next_point_id
		
		# 使用 map_to_local 給 A* 真實座標
		var world_pos = map.map_to_local(cell)
		astar.add_point(next_point_id, world_pos)
		next_point_id += 1
	# 把相鄰的六邊形連成網路
	for cell in cell_to_id:
		var current_id = cell_to_id[cell]
		var neighbors = map.get_surrounding_cells(cell)
		for neighbor in neighbors:
			if cell_to_id.has(neighbor):
				var neighbor_id = cell_to_id[neighbor]
				if not astar.are_points_connected(current_id, neighbor_id):
					astar.connect_points(current_id, neighbor_id)

func spawn_king(grid_pos: Vector2i):
	var king = king_scene.instantiate()
	units_container.add_child(king)
	
	king.grid_pos = grid_pos
	king.position = map.map_to_local(grid_pos)
	
	king.unit_clicked.connect(_on_unit_selected)
	occupied_cells[grid_pos] = king
	
	# 設定為不可通行 (佔用)
	if cell_to_id.has(grid_pos):
		astar.set_point_disabled(cell_to_id[grid_pos], true)

func _on_unit_selected(unit):
	if selected_unit and selected_unit != unit:
		selected_unit.modulate = Color.WHITE
	selected_unit = unit
	print("選取了士兵，位於：", unit.grid_pos)
	unit.modulate = Color.RED # 士兵變色 

func _unhandled_input(event):
	if selected_unit == null:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		# 算出點了哪一格
		var target_grid_pos = map.local_to_map(map.get_local_mouse_position())
		
		# 檢查格子
		if not cell_to_id.has(target_grid_pos):
			print("點擊了地圖外或障礙物！")
			selected_unit.modulate = Color.WHITE # 恢復顏色
			selected_unit = null
			return
		var target_id = cell_to_id[target_grid_pos]
		var start_id = cell_to_id[selected_unit.grid_pos]
		if astar.is_point_disabled(target_id):
			print("目標點已有單位，無法前往！")
			selected_unit.modulate = Color.WHITE # 恢復顏色
			selected_unit = null
			return
		
		# --- 計算路徑 ---
		# 解鎖起點
		astar.set_point_disabled(start_id, false)
		
		# 取得路徑 (回傳的是一系列的世界像素座標)
		var raw_path = astar.get_point_path(start_id, target_id)
		
		if raw_path.size() <= 1: # 沒有路徑，或者只包含起點自己
			print("無法到達目的地！被障礙物擋住了")
			astar.set_point_disabled(start_id, true) # 走不了，把原位鎖回去
			return
		
		# --- 準備執行移動 ---
		occupied_cells.erase(selected_unit.grid_pos)
		occupied_cells[target_grid_pos] = selected_unit
		
		# 更新 A* 障礙
		astar.set_point_disabled(start_id, false)
		astar.set_point_disabled(target_id, true)
		
		# 將 PackedVector2Array 轉為 Unit 腳本需要的 Array[Vector2]
		# 同時跳過 index 0 (因為 index 0 是起點的座標，我們不需要原地踏步)
		var world_path: Array[Vector2] = []
		for i in range(1, raw_path.size()):
			world_path.append(raw_path[i])
			
		selected_unit.walk_along_path(world_path, target_grid_pos)
		
		# 移動完後取消選取 (看你想不想連續移動)
		selected_unit.modulate = Color.WHITE # 恢復顏色
		selected_unit = null
