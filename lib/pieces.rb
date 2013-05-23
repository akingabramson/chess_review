require 'set'
# require 'debugger'
class Piece

  #ASH: smart.  We should have set our deltas in a hash too.

  DELTAS = {
    :south => [1, 0],
    :north => [-1, 0],
    :east => [0, 1],
    :west => [0, -1],
    :se => [1, 1],
    :nw => [-1, -1],
    :ne => [-1, 1],
    :sw => [1, -1],
    :nne => [-2, 1],
    :nnw => [-2, -1],
    :een => [-1, 2],
    :ees => [1, 2],
    :sse => [2, 1],
    :ssw => [2, -1],
    :wwn => [-1, -2],
    :wws => [1, -2]
  }

  attr_accessor :location, :board
  attr_reader :color , :directions, :king
  alias_method :king?, :king

  def initialize(starting_location, color, board)
    @location = starting_location
    @color = color
    @board = board
    @board[*@location] = self #stand in for testing, occupied_by no longer exists
    @king = false
  end


  def valid_move?(position)
    possible_moves.include?(position)
  end

  def possible_moves
    possible_moves = []
    @directions.each do |dir|
      #debugger
      possible_moves += build_path(DELTAS[dir])
    end
    possible_moves
  end

  def move(destination)
    if valid_move?(destination)
      old = @location
      @board[old] = nil
      @location = destination
      @board[destination] = self
    end
  end

  def build_path(dir)
    path = []
    row_offset, col_offset = dir
    row, col = [@location[0] + row_offset, @location[1] + col_offset]
    while Board.in_board?([row, col])
      square_contents = @board[row, col]

      if square_contents.nil? || square_contents.color != @color
        path << [row, col]
      end

      break unless square_contents.nil? #ASH: does this still return path for spaces
      break if self.is_a?(Stepper)      #     where pieces are >2 moves away, or does it just break?
      row += row_offset
      col += col_offset
    end
    path
  end

  def self.place_pieces(board)
    Queen.place_queens(board)
    Rook.place_rooks(board)
    Bishop.place_bishops(board)
    King.place_kings(board)
    Pawn.place_pawns(board)
    Knight.place_knights(board)
  end
end

class Slider < Piece

end

class Stepper < Piece

end


class Queen < Slider


  def initialize(starting_location, color, board)
    super(starting_location, color, board)
    @directions = Set.new [:north, :south, :east, :west, :se, :ne, :sw, :se]
  end

  def to_s
    "Q#{@color}"
  end

  def self.place_queens(board)
    starting_positions = {
      :black => [[0,4]],
      :white => [[7,4]]
    }
    starting_positions.each do |key, value|
      value.each do |coord|
        Queen.new(coord, key, board)
      end
    end
  end
end


class Rook < Slider


  def initialize(starting_location, color, board)
    super(starting_location, color, board)
    @directions = Set.new [:north, :south, :east, :west]
  end

  def to_s
    "R#{@color}"
  end

  def self.place_rooks(board)
    starting_positions = {
      :black => [[0,0], [0,7]],
      :white => [[7,0], [7,7]]
    }
    starting_positions.each do |key, value|
      value.each do |coord|
        Rook.new(coord, key, board)
      end
    end
  end
end


class Bishop < Slider


  def initialize(starting_location, color, board)
    super(starting_location, color, board)
    @directions = Set.new [:ne, :se, :nw, :sw]
  end

  def to_s
    "B#{@color}"
  end

  def self.place_bishops(board)
    starting_positions = {
      :black => [[0,2], [0,5]],
      :white => [[7,2], [7,5]]
    }
    starting_positions.each do |key, value|
      value.each do |coord|
        Bishop.new(coord, key, board)
      end
    end
  end
end


class King < Stepper


  def initialize(starting_location, color, board)
    super(starting_location, color, board)
    @directions = Set.new [:north, :south, :east, :west, :se, :ne, :sw, :sw]
    @king = true
  end

  def to_s
    "King#{@color}"
  end

  def self.place_kings(board)
    starting_positions = {
      :black => [[0,3]],
      :white => [[7,3]]
    }
    starting_positions.each do |key, value|
      value.each do |coord|
        King.new(coord, key, board)
      end
    end
  end
end

class Pawn < Stepper


  def initialize(starting_location, color, board)
    super(starting_location, color, board)
    case @color
    when :black
      @directions = Set.new [:south]
    when :white
      @directions = Set.new [:north]
    end
  end

  def to_s
    "P#{@color}"
  end

  def self.place_pawns(board)

    #ASH: This could probably be looped with just an array of [1,6] and going to 
    #each spot
    starting_positions = {
      :black => [[1,0], [1,1], [1,2], [1,3], [1,4], [1,5], [1,6], [1,7]],
      :white => [[6,0], [6,1], [6,2], [6,3], [6,4], [6,5], [6,6], [6,7]]
    }
    starting_positions.each do |key, value|
      value.each do |coord|
        Pawn.new(coord, key, board)
      end
    end
  end

end


class Knight < Stepper

  def initialize(starting_location, color, board)
    super(starting_location, color, board)
    @directions = Set.new [:nne, :nnw, :een, :ees, :sse, :ssw, :wwn, :wws]
  end

  def to_s
    "K#{@color}"
  end

  def self.place_knights(board)
    starting_positions = {
      :black => [[0,1], [0,6]],
      :white => [[7,1], [7,6]]
    }

    starting_positions.each do |key, value|
      value.each do |coord|
        Knight.new(coord, key, board)
      end
    end
  end
end