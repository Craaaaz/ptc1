extends TileMapLayer

@export var radius: int = 5: # 六邊形地圖的半徑
	set(value):
		radius = value
		generate_hex_map()

func _ready():
	generate_hex_map()

func generate_hex_map():
	clear() # 清空現有地圖
	for q in range(-radius, radius + 1):
		for r in range(-radius, radius + 1):
			var s = -q - r
			if abs(q) <= radius and abs(r) <= radius and abs(s) <= radius:
				set_cell(generate_cord(q,r), 0, Vector2i(0, 0)) # set_cell 參數說明：(格子座標, Source ID, Atlas 座標)

func generate_cord(q,r): #轉換軸座標成Vector2i座標  r 是水平軸 q 是左上到右下 s 是右上到左下
	var vx = q + (r - (r & 1)) / 2
	var vy = r
	return(Vector2i(vx,vy))
