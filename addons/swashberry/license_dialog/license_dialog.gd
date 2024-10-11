extends Window
# A dialog which displays a human-readable list of attribution notices.


# Source: https://github.com/swashdev/redot-license-dialog
# Version 4.0.1-pre.1
# Tested on Redot prerelease builds.


# An enum used by the `_read_copyright_file` function to determine what kind of
# line is being read at the time.
enum { _FILE, _COPYRIGHT, _COMMENT, _LICENSE }

# The name of the project which will be used.  If left blank, this value will be
# replaced with the name of the Redot Engine project.
@export var project_name: String = "" : \
		set = set_project_name, get = get_project_name


# These variables act as shortcuts to nodes within the LicenseDialog which we
# will be accessing frequently.  The reason we do this is that it's cheaper to
# get the node only once and store its reference in a variable than it is to
# get it every time we need to access it, which is helpful for project managers
# who want to optimize their code.
@onready var _info_label = $Container/Label
@onready var _component_list = $Container/ComponentList
@onready var _attribution_popup = $AttributionDialog
@onready var _attribution_textbox = $AttributionDialog/TextBox


# A dictionary which will store licensing information for the game, parsed from
# the game copyright file, and a corresponding TreeItem which will display this
# information.
var project_components: Dictionary = {
	"Redot Pong": [
		{
			"files": ["*"],
			"copyright": ["2024 swashberry"],
			"license": ["Unlicense"]
		},
	],
	"License Dialog for Redot": [
		{
			"files": ["addons/swashberry/license_dialog/*"],
			"copyright": ["2021, 2024 swashberry"],
			"license": ["Unlicense"]
		}
	],
}
var project_components_tree: TreeItem

# A dictionary which will store licensing information for the Redot Engine,
# parsed from data collected from the engine itself, and a corresponding
# TreeItem which will display this information.
var _redot_components: Dictionary = {}
var _redot_components_tree: TreeItem

# A dictionary which will store the full text of the licensing gathered from
# the above sources, and a TreeItem which will display this information.
var _licenses: Dictionary = {
	"Unlicense": \
"This is free and unencumbered software released into the public domain.\n\n" +
"Anyone is free to copy, modify, publish, use, compile, sell, or\n" +
"distribute this software, either in source code form or as a compiled\n" +
"binary, for any purpose, commercial or non-commercial, and by any\n" +
"means.\n\n" +
"In jurisdictions that recognize copyright laws, the author or authors\n" +
"of this software dedicate any and all copyright interest in the\n" +
"software to the public domain. We make this dedication for the benefit\n" +
"of the public at large and to the detriment of our heirs and\n" +
"successors. We intend this dedication to be an overt act of\n" +
"relinquishment in perpetuity of all present and future rights to this\n" +
"software under copyright law.\n\n" +
"THE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND,\n" +
"EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF\n" +
"MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.\n" +
"IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR\n" +
"OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,\n" +
"ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR\n" +
"OTHER DEALINGS IN THE SOFTWARE.\n\n" +
"For more information, please refer to <https://unlicense.org>\n",
}
var _licenses_tree: TreeItem


func _ready():
	# Set the label text appropriately.
	var game_name = project_name
	if game_name == "":
		game_name = ProjectSettings.get_setting( "application/config/name" )

	# Create the root for the component list tree.
	var root = _component_list.create_item()
	
	# Create a subtree for the project components list.
	project_components_tree = _component_list.create_item( root )
	project_components_tree.set_text( 0, game_name )
	project_components_tree.set_selectable( 0, false )
	for component in project_components:
		var component_item = _component_list.create_item(
				project_components_tree )
		component_item.set_text( 0, component )

	# Create a subtree for the Redot Engine components list.
	_redot_components_tree = _component_list.create_item( root )
	_redot_components_tree.set_text( 0, "Redot Engine" )
	_redot_components_tree.set_selectable( 0, false )

	# Populate the Redot Engine components subtree.
	var components: Array = Engine.get_copyright_info()
	for component in components:
		var component_item = _component_list.create_item( _redot_components_tree
				)
		component_item.set_text( 0, component["name"] )
		_redot_components[component["name"]] = component["parts"]

	# The `_licenses` dictionary has already been populated by
	# `_read_copyright_file` but still needs to be populated with licenses from
	# the Redot Engine.
	var license_info: Dictionary = Engine.get_license_info()
	var keys = license_info.keys()
	var key_count: int = keys.size()
	for index in key_count:
		_licenses[keys[index]] = license_info[keys[index]]
	
	# Create a subtree for the licenses list.
	_licenses_tree = _component_list.create_item( root )
	_licenses_tree.set_text( 0, "Licenses" )
	_licenses_tree.set_selectable( 0, false )

	# Populate the Licenses subtree.
	keys = _licenses.keys()
	# Sort the keys so that the licenses will be displayed in alphabetical
	# order.
	keys.sort()
	key_count = keys.size()
	for index in key_count:
		var license_item = _component_list.create_item( _licenses_tree )
		license_item.set_text( 0, keys[index] )
		license_item.set_selectable( 0, true )


func set_project_name( new_name: String ):
	project_name = new_name


func get_project_name() -> String:
	return project_name


func set_label_text( text: String ):
	_info_label.text = text


func _on_ComponentList_item_selected():
	var selected: TreeItem = _component_list.get_selected()
	var parent: TreeItem = selected.get_parent()
	var comp_title: String = selected.get_text( 0 )
	var parent_title: String = parent.get_text( 0 )
	
	if parent_title == "Redot Engine":
		_display_game_component_info(comp_title, _redot_components[comp_title])
	elif parent_title == "Licenses":
		_display_license_info(comp_title)
	else:
		_display_game_component_info(comp_title, project_components[comp_title])


func _display_game_component_info(comp_title: String, component: Array):
	var text: String = comp_title

	for part in component:
		text += "\n\nFiles:"
		for file in part["files"]:
			text += "\n    %s" % file
		text += "\n"
		for copyright in part["copyright"]:
			text += "\nCopyright (c) %s" % copyright
		text += "\nLicense: %s" % part["license"]

	_popup_attribution_dialog(comp_title, text)


func _display_license_info(key: String):
	_popup_attribution_dialog( key, _licenses[key] )


func _popup_attribution_dialog( component: String, text: String ):
	_attribution_popup.set_title( component )
	_attribution_textbox.set_text( text )
	_attribution_textbox.scroll_vertical = 0
	_attribution_textbox.scroll_horizontal = 0
	_attribution_popup.popup_centered()


func close() -> void:
	pass # Replace with function body.
