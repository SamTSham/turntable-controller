# encoding: UTF-8
# Copyright 2026 Sam Madwar
# Licensed under the Apache License, Version 2.0. See LICENSE.
require 'sketchup.rb'
require 'json'
require 'base64'
module SamTurntable
  module Core
    @@dlg = nil
    @@help_dialog = nil
    @@animation_timer = nil
    ATTR_DICT = 'SamTurntable'.freeze
    DATA_VERSION = 1
    NAME_REGEX = /#Turntable#/i
    PREF_NS   = 'SamTurntableUI'.freeze

    def self.find_target
      model = Sketchup.active_model
      return nil unless model
      root = turntable_candidates(model.entities)
      selected = model.selection.to_a.select { |e| turntable_entity?(e) }
      direct = selected + root
      direct.find { |e| turntable_name?(e) } ||
        direct.find { |e| turntable_data?(e) } ||
        nested_turntable(model.entities)
    end

    def self.turntable_entity?(ent)
      ent.is_a?(Sketchup::Group) || ent.is_a?(Sketchup::ComponentInstance)
    end

    def self.turntable_candidates(entities)
      entities.to_a.select { |e| turntable_entity?(e) }
    end

    def self.turntable_data?(ent)
      ent.get_attribute(ATTR_DICT, 'controlled', false) == true ||
        !ent.get_attribute(ATTR_DICT, 'pegs', nil).nil?
    end

    def self.nested_turntable(entities, visited = {})
      turntable_candidates(entities).each do |ent|
        return ent if turntable_name?(ent) || turntable_data?(ent)
      end
      turntable_candidates(entities).each do |ent|
        definition = ent.respond_to?(:definition) ? ent.definition : nil
        next unless definition && !visited[definition.object_id]
        visited[definition.object_id] = true
        found = nested_turntable(definition.entities, visited)
        return found if found
      end
      nil
    end

    def self.turntable_name?(ent)
      instance_name = ent.respond_to?(:name) ? ent.name.to_s : ''
      definition_name = ent.respond_to?(:definition) ? ent.definition.name.to_s : ''
      !!(instance_name =~ NAME_REGEX || definition_name =~ NAME_REGEX)
    end

    
def self.get_angle(ent)
  aa = ent.get_attribute(ATTR_DICT, 'angle_deg', nil)
  ad = derive_angle_from_transform(ent).to_f rescue 0.0
  if aa.nil?
    return ad
  else
    aa = aa.to_f
    return ad if (aa - ad).abs >= 0.5
    return aa
  end
end

    def self.set_angle(ent, deg); ent.set_attribute(ATTR_DICT, 'angle_deg', deg.to_f % 360.0); end
    def self.get_speed(ent); ent.get_attribute(ATTR_DICT, 'sec_per_rev', 60.0).to_f; end
    def self.set_speed(ent, secs); ent.set_attribute(ATTR_DICT, 'sec_per_rev', secs.to_f); end
    def self.get_easing(ent); [[ent.get_attribute(ATTR_DICT, 'easing', 1.0).to_f, 0.0].max, 1.0].min; end
    def self.set_easing(ent, value); ent.set_attribute(ATTR_DICT, 'easing', [[value.to_f, 0.0].max, 1.0].min); end
    def self.get_pegs(ent)
      pegs = JSON.parse(ent.get_attribute(ATTR_DICT, 'pegs', '[]').to_s)
      pegs.is_a?(Array) ? pegs : []
    rescue JSON::ParserError, TypeError
      []
    end

    def self.set_pegs(ent, arr)
      return false unless ent && arr.is_a?(Array)
      ent.set_attribute(ATTR_DICT, 'data_version', DATA_VERSION)
      ent.set_attribute(ATTR_DICT, 'controlled', true)
      ent.set_attribute(ATTR_DICT, 'pegs', JSON.generate(arr))
      true
    end

    # Small public boundary for future Toolkit integration. Turntable remains
    # optional; callers can fall back to ordinary transform keyframes.
    def self.api_version; DATA_VERSION; end
    def self.controlled_entity; find_target; end
    def self.controls?(ent); !ent.nil? && ent == find_target; end

    def self.pivot_origin(ent); ent.bounds.center; end
    def self.pivot_axis(ent);   ent.transformation.zaxis; end

    
def self.derive_angle_from_transform(ent)
  t = ent.transformation
  # angle around Z relative to world x-axis (in degrees 0..360)
  x = t.xaxis
  ang = Math.atan2(x.y, x.x) * 180.0 / Math::PI
  ang = ang % 360.0
  ang < 0 ? ang + 360.0 : ang
end

    def self.rotate_to(ent, target_deg)
      cancel_animation
      current = get_angle(ent)
      delta   = (target_deg.to_f - current)
      return if delta.abs < 1e-6
      ent.transform!(Geom::Transformation.rotation(pivot_origin(ent), pivot_axis(ent), delta.degrees))
      set_angle(ent, target_deg.to_f)
    end

    def self.animate_to(ent, target_deg, sec_per_rev, long_way=false, multiplier=1.0, easing=1.0)
      cancel_animation
      current = get_angle(ent)
      desired = target_deg.to_f % 360.0
      delta = (desired - current) % 360.0
      delta -= 360.0 if delta > 180.0
      delta += (delta >= 0 ? -360.0 : 360.0) if long_way
      total = delta.abs
      return rotate_to(ent, desired) if total < 0.1

      sec = [sec_per_rev.to_f, 0.001].max
      sec = sec / [multiplier.to_f, 0.001].max
      deg_per_sec = 360.0 / sec
      duration = total / deg_per_sec

      start = Time.now; last = current
      origin = pivot_origin(ent); axis = pivot_axis(ent)
      view = Sketchup.active_model.active_view
      timer = UI.start_timer(0.01, true) do
        t = Time.now - start
        frac = [[t / duration, 1.0].min, 0.0].max
        smooth = frac * frac * (3 - 2 * frac)
        mix = [[easing.to_f, 0.0].max, 1.0].min
        eased = frac * (1.0 - mix) + smooth * mix
        step = current + delta * eased
        inc = step - last
        if inc.abs >= 1e-6
          ent.transform!(Geom::Transformation.rotation(origin, axis, inc.degrees))
          last = step
          view.invalidate
          begin; @@dlg && @@dlg.execute_script("window.sketchup_anim && window.sketchup_anim(" + step.round.to_s + ")"); rescue; end
        end
        if frac >= 1.0 - 1e-6
          UI.stop_timer(timer)
          @@animation_timer = nil if @@animation_timer == timer
          set_angle(ent, desired)
          begin; @@dlg && @@dlg.execute_script("window.sketchup_anim && window.sketchup_anim(" + desired.round.to_s + ")"); rescue; end
        end
      end
      @@animation_timer = timer
    end

    def self.cancel_animation
      return unless @@animation_timer
      UI.stop_timer(@@animation_timer)
      @@animation_timer = nil
    rescue StandardError
      @@animation_timer = nil
    end

    def self.send_pegs(dialog)
      ent = find_target
      pegs = ent ? get_pegs(ent) : []
      data = Base64.strict_encode64(JSON.generate(pegs))
      dialog.execute_script("window.sketchup._pegs_b64('#{data}');")
      dialog.execute_script("window.samTurntableLoadResult(#{!ent.nil?}, #{pegs.length})")
    end

    def self.send_state(dialog)
      ent = find_target
      if ent
        derived = derive_angle_from_transform(ent).to_f rescue 0.0
        stored = ent.get_attribute(ATTR_DICT, 'angle_deg', nil)
        angle = if stored.nil? || (stored.to_f - derived).abs >= 0.5
                  set_angle(ent, derived)
                  derived
                else
                  stored.to_f
                end
        payload = { angle: angle, speed: get_speed(ent), easing: get_easing(ent) }
      else
        payload = { angle: 0.0, speed: 60.0, easing: 1.0 }
      end
      data = Base64.strict_encode64(payload.to_json)
      dialog.execute_script("window.sketchup._state_b64('#{data}')")
    end

    def self.refresh_dialog(delays = [0.0])
      dialog = @@dlg
      return unless dialog
      delays.each do |delay|
        UI.start_timer(delay, false) do
          begin
            next unless @@dlg == dialog
            send_pegs(dialog)
            send_state(dialog)
          rescue StandardError
          end
        end
      end
    end

    def self.read_pref(name, default); Sketchup.read_default(PREF_NS, name, default); end
    def self.write_pref(name, value); Sketchup.write_default(PREF_NS, name, value); end

    def self.open_dialog
      html = File.join(File.dirname(__FILE__), 'ui', 'index.html')
      dlg = UI::HtmlDialog.new(
        dialog_title: 'Turntable',
        style: UI::HtmlDialog::STYLE_DIALOG,
        width: read_pref('w', 520).to_i,
        height: read_pref('h', 230).to_i,
        resizable: true,
        preferences_key: 'sam_turntable_v032'
      )
      dlg.set_file(html)
      @@dlg = dlg

      dlg.add_action_callback('scrub') do |d, arg|
        ent = find_target
        rotate_to(ent, (arg.to_f + 360.0) % 360.0) if ent
      end

      dlg.add_action_callback('go') do |d, arg|
        ent = find_target
        if ent
          parts = arg.split(',')
          t_abs = parts[0].to_f
          speed = parts[1].to_f
          longf = parts[2].to_i == 1
          mult  = parts[3].to_f
          anim  = parts[4].to_i == 1
          easing = parts[5].nil? ? get_easing(ent) : parts[5].to_f
          set_speed(ent, speed)
          set_easing(ent, easing)
          if anim
            animate_to(ent, t_abs, speed, longf, mult, easing)
          else
            rotate_to(ent, t_abs)
          end
        end
      end

      dlg.add_action_callback('jump') do |d, arg|
        ent = find_target
        rotate_to(ent, arg.to_f % 360.0) if ent
      end

      dlg.add_action_callback('easing_set') do |_d, arg|
        ent = find_target
        set_easing(ent, arg) if ent
      end

      dlg.add_action_callback('help') { |_d, _arg| open_help }

      dlg.add_action_callback('pegs_get') do |d,_|
        send_pegs(d)
      end

      dlg.add_action_callback('pegs_set') do |d, arg|
        ent = find_target
        ok = false
        message = 'No group or component named #Turntable# was found.'
        begin
          if ent
            json = Base64.strict_decode64(arg.to_s)
            arr = JSON.parse(json)
            ok = set_pegs(ent, arr)
            message = ok ? 'Saved in model.' : 'Peg data was not an array.'
          end
        rescue JSON::ParserError, TypeError, ArgumentError => error
          message = error.message
        end
        encoded = Base64.strict_encode64(message)
        d.execute_script("window.samTurntableSaveResult(#{ok}, '#{encoded}')")
      end

      

      dlg.add_action_callback('state') { |d,_| send_state(d) }

      dlg.add_action_callback('save_ui') do |d, arg|
        w, h = arg.split(',').map(&:to_i)
        write_pref('w', w); write_pref('h', h)
      end

      dlg.show
      # The HTML bridge and a startup-restored model can finish asynchronously.
      refresh_dialog([0.1, 0.5, 1.25])
    end

    def self.open_help
      if @@help_dialog && @@help_dialog.visible?
        @@help_dialog.bring_to_front
        return
      end
      help_file = File.join(File.dirname(__FILE__), 'ui', 'help.html')
      @@help_dialog = UI::HtmlDialog.new(
        dialog_title: 'Turntable Controller — Quick Guide',
        style: UI::HtmlDialog::STYLE_DIALOG,
        width: 470,
        height: 590,
        min_width: 380,
        min_height: 360,
        resizable: true,
        scrollable: true,
        preferences_key: 'sam_turntable_help_v1'
      )
      @@help_dialog.set_file(help_file)
      @@help_dialog.set_on_closed { @@help_dialog = nil }
      @@help_dialog.show
    end

    class ModelObserver < Sketchup::AppObserver
      def expectsStartupModelNotifications; true; end
      def onNewModel(_model); Core.refresh_dialog([0.0, 0.25, 0.8]); end
      def onOpenModel(_model); Core.refresh_dialog([0.0, 0.25, 0.8]); end
      def onActivateModel(_model); Core.refresh_dialog([0.0, 0.15]); end
      def onExtensionsLoaded; Core.refresh_dialog([0.2, 0.8]); end
    end

    unless @observer
      @observer = ModelObserver.new
      Sketchup.add_observer(@observer)
    end

    unless @menu_built
      UI.menu('Extensions').add_item('Turntable') { open_dialog }
      @menu_built = true
    end
  end
end
