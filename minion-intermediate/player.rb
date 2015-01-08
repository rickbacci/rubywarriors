require 'objects'
require 'objectives'

require 'intel'
require 'warrior_actions'

require 'warrior_listens'
require 'warrior_looks'
require 'warrior_feels'

require 'debugging'


class Player

  def initialize
    @possible_objectives ||= [:ticking_captive, :captive, :enemy_threat,:enemy_bound]
    @path_traveled ||= []
    @objectives = []
    @stairs ||= false
    @warrior_health ||= 20
    @debugging if @debugging.nil?
    @log = []
  end


  def play_turn(warrior)
    record_action

    @warrior = warrior


    reset_objectives
    create_objects
    build_objectives

    # debugging
    # what_warrior_hears


    if objectives_accomplished

      warrior_walk(towards_stairs)
    elsif nowhere_to_move

      if next_to_captive
        rescue_captive
      elsif multiple_enemies_near?
        bind_enemies
      else
        blow_stuff_up(towards_objective)
      end

    elsif three_front_war

      warrior_retreat

    elsif perfect_bomb_location

      if warrior_critical
        warrior_rest
      else
        blow_stuff_up(look_for_direction)
      end

    elsif any_captives?

      if next_objective.ticking
        if next_to_captive
          rescue_captive
        else
          walk_towards_objective
        end
      elsif next_to_captive
        rescue_captive
      elsif next_to_last_enemy
        attack_enemy
      else
        walk_towards_objective
      end

    elsif warrior_wounded && safe_to_rest

      warrior_rest

    elsif warrior_critical && !one_enemy_left?

      warrior_retreat

    elsif danger_far

      if path_clear
        walk_towards_objective
      else
        blow_stuff_up
      end

    elsif danger_close

      if multiple_enemies_near?
        blow_stuff_up
      else
        attack_enemy
      end

    elsif bound_enemies?

      if bound_enemy_close
        attack_enemy
      else
        walk_towards_objective
      end

    else

      walk_towards_objective

    end

    @warrior_health = warrior.health

    print_log
  end
end
