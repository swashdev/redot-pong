# This file can be used to build a Redot release template which is optimized
# for Redot Pong's specific needs.  To use it, enter the path to this file as
# the "profile" parameter in a `scons` call.  I would also recommend using
# `optimize=size` to get an even smaller binary.

extra_suffix = "redot_pong"


openxr = "no"


modules_enabled_by_default = "no"
module_gdscript_enabled = "yes"

disable_3d = "yes"
deprecated = "no"

# We need advanced GUI for the menus (for now)
disable_advanced_gui = "no"

module_freetype_enabled = "yes"
module_text_server_fb_enabled = "yes"
