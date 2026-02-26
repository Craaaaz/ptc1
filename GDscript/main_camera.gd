extends Camera2D

var dragging = false
var last_mouse_pos = Vector2()

func _unhandled_input(event):
	# 1. 偵測左鍵按下與放開
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				# 開始拖拽，記錄起始點
				dragging = true
				last_mouse_pos = event.position
			else:
				# 停止拖拽
				dragging = false

	# 2. 處理移動邏輯
	if event is InputEventMouseMotion and dragging:
		# 計算滑鼠移動了多少像素
		var delta = event.position - last_mouse_pos
		
		# 這裡要將移動量乘以相機的 Zoom，確保縮放時拖拽速度依然跟手
		# 注意：相機移動方向與滑鼠移動方向相反，所以用減法
		position -= delta * zoom
		
		# 更新最後一次位置
		last_mouse_pos = event.position
