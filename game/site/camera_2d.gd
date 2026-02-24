extends Camera2D

# 縮放設定
@export var zoom_speed: float = 0.1
@export var min_zoom: float = 0.5
@export var max_zoom: float = 3.0

# 拖動狀態
var is_dragging = false

func _input(event):
	# --- 拖動邏輯 ---
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			is_dragging = event.pressed
	
	if event is InputEventMouseMotion and is_dragging:
		position -= event.relative * (1.0 / zoom.x) # 修正：除以 zoom 讓拖動手感在不同縮放下一致
	
	# --- 縮放邏輯 (滾輪) ---
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_set_zoom_level(zoom_speed)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_set_zoom_level(-zoom_speed)

	# --- 3. 回歸零點邏輯 (空白鍵) ---
	if event is InputEventKey:
		# 檢查是否按下空白鍵 (KEY_SPACE) 且是按下狀態 (pressed)
		if event.pressed and event.keycode == KEY_SPACE:
			_reset_camera()

# 處理縮放的輔助函數
func _set_zoom_level(delta):
	var target_zoom = clamp(zoom.x + delta, min_zoom, max_zoom)
	zoom = Vector2(target_zoom, target_zoom)

# 處理回歸零點的輔助函數
func _reset_camera():
	var tween = create_tween()
	tween.tween_property(self, "position", Vector2.ZERO, 0.5).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
