extends Node2D

func generate_tilemap_from_bodies(bodies:Array):
	$TileMap.cell_size = Vector2.ONE * Global.TILE_SIZE
	
