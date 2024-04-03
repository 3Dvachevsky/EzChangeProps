@tool
extends EditorPlugin

var selected_node : Node3D

func _handles(object):
	if object is Node3D:
		selected_node = object
		return true
	return false

func _forward_3d_gui_input(camera, event) -> int:
	if Input.is_key_pressed(KEY_ALT):
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_WHEEL_UP) or Input.is_mouse_button_pressed(MOUSE_BUTTON_WHEEL_DOWN):
			if event.is_pressed() and event.button_index == MOUSE_BUTTON_WHEEL_UP:
				_change(+1)
			if event.is_pressed() and event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				_change(-1)
		return 1
	return 0

func _change(value):
	var scenes : Array[PackedScene] = _get_all_scenes()
	
	if scenes.size() == 1 or scenes == [] or scenes == null:
		return
	
	var index_tree : float = selected_node.get_index()
	var i : float = scenes.find(load(selected_node.scene_file_path))
	var transform_node = selected_node.transform
	
	if i + value < 0:
		i = scenes.size() - 1
	elif i + value > scenes.size() - 1:
		i = 0
	else:
		i = i + value
	
	var new_node : Node3D = scenes[i].instantiate()
	var parent = EditorInterface.get_edited_scene_root().get_node_or_null(selected_node.get_path()).get_parent()
	var node_name : String = selected_node.scene_file_path.get_basename().get_slice("/", selected_node.scene_file_path.get_base_dir().get_slice_count("/"))
	
	parent.add_child(new_node)
	parent.move_child(new_node, index_tree)
	new_node.set_owner(selected_node.get_owner())
	new_node.transform = transform_node
	new_node.set_name(node_name)
	selected_node.free()
	
	EditorInterface.get_selection().clear()
	EditorInterface.get_selection().add_node(new_node)
	EditorInterface.mark_scene_as_unsaved()

func _get_all_scenes():
	var scenes : Array[PackedScene]
	var selected_node : Node = EditorInterface.get_selection().get_selected_nodes()[0]
	var path_to_selected_node : String = selected_node.scene_file_path.get_base_dir()
	
	if path_to_selected_node == "":
		return scenes
	
	var dir = DirAccess.open(path_to_selected_node)
	for file in dir.get_files():
		var load_file = load(path_to_selected_node + "/" + file)
		if load_file.get_class() == "PackedScene":
			scenes.append(load_file)
	
	return scenes
