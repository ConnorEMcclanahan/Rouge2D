extends TileMapLayer
## Cliffs are solid (you can't walk up onto them).
## The player hops DOWN off them by detecting this layer by name during
## downward movement (see player.gd).

func _ready() -> void:
	if tile_set == null:
		return
	var cell_size := Vector2(tile_set.tile_size)
	for cell in get_used_cells():
		var td := get_cell_tile_data(cell)
		if td == null:
			continue
		# Full-tile rectangle so the whole cliff face is solid
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
	# Rebuild physics bodies so the new polygons take effect
	if has_method("notify_runtime_tile_data_update"):
		notify_runtime_tile_data_update()
	set_cell(Vector2i(1000000, 1000000), -1)

