extends TileMapLayer
## Makes every tile in this layer solid at runtime.
## Some bushes/decor in the pack have no physics polygons, so we add
## a full-tile rectangle to any tile that lacks collision.

func _ready() -> void:
	if tile_set == null:
		return
	var cell_size := Vector2(tile_set.tile_size)
	for cell in get_used_cells():
		var td := get_cell_tile_data(cell)
		if td == null:
			continue
		# Replace any partial polygon with a full-tile rectangle so the whole
		# tree/bush is solid (native polygons only cover part of some trees)
		while td.get_collision_polygons_count(0) > 0:
			td.remove_collision_polygon(0, 0)
		var source := tile_set.get_source(get_cell_source_id(cell)) as TileSetAtlasSource
		var atlas_size := Vector2i(1, 1)
		if source != null:
			atlas_size = source.get_tile_size_in_atlas(get_cell_atlas_coords(cell))
		var size := Vector2(atlas_size) * cell_size
		td.add_collision_polygon(0)
		var polygon_index := td.get_collision_polygons_count(0) - 1
		td.set_collision_polygon_points(0, polygon_index, PackedVector2Array([
			Vector2.ZERO, Vector2(size.x, 0), Vector2(size.x, size.y), Vector2(0, size.y),
		]))
	# Rebuild the layer's physics bodies so the new polygons take effect
	if has_method("notify_runtime_tile_data_update"):
		notify_runtime_tile_data_update()
	# Fallback: touching a far-away cell forces a physics rebuild on any version
	set_cell(Vector2i(1000000, 1000000), -1)
