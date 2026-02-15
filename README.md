# customizable-packed-scene
Simple custom resource that allows you to modify the exported variables of a packed scene without modifying the referenced scene.

![Demonstration of the customizable packed scene script](images/demo.gif)

This is a fork of (micycle8778/customizable-packed-scene)[https://github.com/micycle8778/customizable-packed-scene] that cleans up the code a little, adds comments, and updates to Godot's modern plugin format.

Changes from the original:
- Doc comments on everything
- `plugin.cfg` file
- Remove unecessary `PackedScene.instantiate` calls
- Fix potential memory leak issues from instantiated nodes not being freed
