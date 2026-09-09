# encoding: UTF-8
# Copyright 2026 Sam Madwar
# Licensed under the Apache License, Version 2.0. See Turntable/LICENSE.
require 'sketchup.rb'
require 'extensions.rb'
module SamTurntable
  EXTENSION_NAME = 'Turntable Controller'.freeze
  unless file_loaded?(__FILE__)
    ex = SketchupExtension.new(EXTENSION_NAME, 'Turntable/main')
    ex.description = 'Compact theatrical revolve control with named pegs, timed transitions, snapping, long-way movement, and adjustable acceleration/deceleration. Settings are stored inside each SketchUp model.'
    ex.version     = '1.0.1'
    ex.creator     = 'Sam Madwar'
    ex.copyright   = 'Copyright 2026 Sam Madwar'
    Sketchup.register_extension(ex, true)
    file_loaded(__FILE__)
  end
end
