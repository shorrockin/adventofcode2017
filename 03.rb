class SpiralGrid

  DIRECTIONS = {
    right: { step: ->(x, y){ [x + 1, y    ] }, check: :max_x, next_direction: :up    },
    up:    { step: ->(x, y){ [x    , y + 1] }, check: :max_y, next_direction: :left  },
    left:  { step: ->(x, y){ [x - 1, y    ] }, check: :min_x, next_direction: :down  },
    down:  { step: ->(x, y){ [x    , y - 1] }, check: :min_y, next_direction: :right }
  }

  def self.val_of(target)
    target_sq     = target
    current_sq    = 1
    current_coord = [0, 0]

    direction = :right
    max_y = 0
    min_y = 0
    max_x = 0
    min_x = 0

    value = nil

    grid = Hash.new(0)
    grid['[0, 0]'] = 1

    while current_sq != target_sq

      d_obj = DIRECTIONS[direction]

      # proceed 1 step
      #
      current_coord = d_obj[:step][*current_coord]
      current_sq += 1

      value = [
        grid[[current_coord[0] - 1, current_coord[1] + 1].to_s],  # top left
        grid[[current_coord[0]    , current_coord[1] + 1].to_s],  # top center
        grid[[current_coord[0] + 1, current_coord[1] + 1].to_s],  # top right
        grid[[current_coord[0] - 1, current_coord[1]    ].to_s],  #     left
        grid[[current_coord[0] + 1, current_coord[1]    ].to_s],  #     right
        grid[[current_coord[0] - 1, current_coord[1] - 1].to_s],  # bot left
        grid[[current_coord[0]    , current_coord[1] - 1].to_s],  # bot center
        grid[[current_coord[0] + 1, current_coord[1] - 1].to_s],  # bot right
      ].reduce(&:+)

      grid[current_coord.to_s] = value

      # check if we've gone too far
      #
      time_to_turn =
        case d_obj[:check]
        when :max_x
          current_coord[0] == max_x + 1
        when :max_y
          current_coord[1] == max_y + 1
        when :min_x
          current_coord[0] == min_x - 1
        when :min_y
          current_coord[1] == min_y - 1
        end

      if time_to_turn
        case d_obj[:check]
        when :max_x
          max_x += 1
        when :max_y
          max_y += 1
        when :min_x
          min_x -= 1
        when :min_y
          min_y -= 1
        end

        direction = d_obj[:next_direction]
      end
    end

    [current_coord, value]
  end
end

coord = nil

(3..90).each do |idx|
  coord = SpiralGrid.val_of(idx)

  break if coord[1] > 312051
end

p coord
