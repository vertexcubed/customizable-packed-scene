@tool
@icon("res://addons/customizable_packed_scene/icon.svg")
class_name CustomizablePackedScene
extends Resource
## A wrapper for a [PackedScene] that can have its properties set in the editor.
##
## CustomizablePackedScene is useful for projects using exported PackedScenes. 
## Normally, when you assign a scene to an exported property, you can't override the default properties of the underlying scene. This wrapper type aims to fix that.
## [br]
## In most cases, you should just use a regular [PackedScene].
## [br]
## Limitations: if the scene script's exported properties change, you'll probably have to reload the editor or remake the CustomizablePackedScene resource

# Implementation based on https://github.com/micycle8778/customizable-packed-scene but modified to have comments and not leak lmao

## The scene to expose. Scenes marked as tool scripts might have issues, but not sure.
## [br]
## [b]Note[/b]: this wrapper will instantiate a copy of this PackedScene when this is set, however it won't be added to any scene tree. 
## If your scene's root node is a [annotation @GDScript.@tool] script, make sure this doesn't cause any issues!
@export var scene: PackedScene:
	set(value):
		scene = value
		overrides = {}
		if is_instance_valid(_internal_instance):
			_internal_instance.queue_free()
		if value:
			_internal_instance = value.instantiate()
		else:
			_internal_instance = null
		notify_property_list_changed()

## The overriden properties set by this [CustomizablePackedScene]. Avoid writing to manually.
var overrides: Dictionary = {}

# Internal node instance used to read properties from. Should be freed automatically.
var _internal_instance: Node


## Instantiates the underlying PackedScene. See [member PackedScene.instantiate]
func instantiate(edit_state: PackedScene.GenEditState = PackedScene.GEN_EDIT_STATE_DISABLED) -> Node:
	assert(scene, "Cannot instantiate null scene")
	var out := scene.instantiate(edit_state)
	for property in overrides:
		out.set(property, overrides[property])
	return out
	
	
func _notification(what: int) -> void:
	match what:
		NOTIFICATION_PREDELETE:
			if is_instance_valid(_internal_instance):
				_internal_instance.queue_free()
	
func _get(property: StringName) -> Variant:
	if not scene:
		return null
	if property in overrides:
		return overrides[property]
	return _internal_instance.get_script().get_property_default_value(property)

func _set(property: StringName, value: Variant) -> bool:
	if not scene:
		return false
	overrides[property] = value
	return true

func _get_property_list() -> Array[Dictionary]:
	if not scene:
		return []
	return (_internal_instance
		.get_script()
		.get_script_property_list()
		.filter(func(property): \
			return property["usage"] & PROPERTY_USAGE_EDITOR != 0 and \
			property["usage"] & PROPERTY_USAGE_SCRIPT_VARIABLE)
	)

func _property_can_revert(property: StringName) -> bool:
	return property in overrides

func _property_get_revert(property: StringName) -> Variant:
	if property in overrides:
		return _internal_instance.get(property)
	return null

