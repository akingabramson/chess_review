#ASH: Asher's comments will be preceded by ASH:

#ASH: Overall notes:  I love how concise and separated your code is.  It makes sense
#that the pieces build themselves and you were very good about keeping methods short overall.
#There are a few places where you can experiment with raising exceptions instead of looping
#until you get a valid input.



require './pieces.rb'
class Board

  attr_accessor :squares, :colors
  #Maybe initialize pieces when we generate the board, put pieces where they need to start




  #EXAMPLE MOVE
  #pos= f4 #player enters postion
  #[(4-1), col_hash[f]]   reverse order, subtract one from
                          #row to match index, pull value from COL_HASH

  def initialize(squares = self.class.blank_squares)
    @squares = squares
    @colors = [:black, :white]
    Piece.place_pieces(self)
    #ASH: might be worth asking whether the board should be placing the pieces, or the piece itself.
  end


  def [](row, col)
    @squares[row][col]
  end

  def []=(row, col, piece)
    old_row, old_col = piece.location
    @squares[old_row][old_col] = nil

    taken = @squares[row][col]
    taken.location = nil if taken
    #ASH: might want to comment what's happening, e.g. if there's a piece in taken, then take it away

    @squares[row][col] = piece
    piece.location = [row, col]
    #ASH: e.g, set new piece down
  end

  def active_pieces(color)
    active_pieces = []
    @squares.each do |row|
      row.each do |sq|
        active_pieces << sq if !sq.nil? and sq.color == color
      end
    end
    active_pieces
  end

  def self.in_board?(position)
    position.all? {|coord| coord.between?(0, 7)}
  end

  def move_piece(start_pos, end_pos)
    piece = self[*start_pos]

    #ASH: if piece isn't nil, then clone 
    #the board and check to see if the move turns into check.  good

    unless piece.nil?
      # debugger
      if piece.valid_move?(end_pos)
        board_copy = clone_board
        board_copy.move_piece!(start_pos, end_pos)

        if board_copy.check?(piece.color)
          return false
        else
          move_piece!(start_pos, end_pos)
          return true
        end
      end
    end
    false
  end

  def move_piece!(start_pos, end_pos) #should return true if the move was valid
    #debugger
    piece = self[*start_pos]
    self[*end_pos] = piece
  end

  def check?(color)
    king = king(color)

    #ASH: this returns an array containing the opposite color.  You can even reference the [0]
    #on this line to be more specific
    opponent = @colors.reject {|cl| cl == king.color} 
    #ASH: I'm getting an error here for calling .color on a blank array
    all_possible_destinations(opponent[0]).include?(king.location)
  end


  def checkmate?(color)
    active_pieces(color).each do |piece|
     current_moves = piece.possible_moves
      current_moves.each do |move|
        ghost_board = self.clone_board
        ghost_king = ghost_board.king(color)
        ghost_board.move_piece(piece.location, move)
        return false unless ghost_board.check?(ghost_king)
      end
    end
    true
  end


  def clone_board
    #debugger
    ghost_board = self.clone
    ghost_board.squares = @squares.map do |row|
      row.map do |piece|
        unless piece.nil?
          piece.clone
        end
      end
    end


    set_clone_pieces(ghost_board)
    ghost_board
  end

  def set_clone_pieces(ghost_board)
    ghost_board.squares.each do |row|
      row.each do |piece|
        piece.board = ghost_board unless piece.nil?
      end
    end
    ghost_board
  end

  def all_possible_destinations(color)
    #debugger
    all_possible_destinations = []
    active_pieces(color).each do |piece|
      all_possible_destinations += piece.possible_moves
    end
    all_possible_destinations
  end

  def king(color)
    active_pieces(color).each do |piece|
      return piece if piece.king?
    end
  end

  def display
    columns = ["a", "b", "c", "d", "e", "f", "g", "h"]
    puts columns.join("          ")
    @squares.each_with_index do |row, index|
      print "#{index}"
      r = row.map do |sq|
        sq.to_s.rjust(10)
      end
      puts r.join("|")
      #puts "--------------------------------------------------------------------------------------------------------"
    end
    nil
  end

  # private

  #ASH: you can shorten this method by calling Array.new(8) {Array.new(8)}.  All on one line.
  def self.blank_squares
    squares = []
    8.times do |row_index|
      squares << []
      8.times do
        squares[row_index] << nil
      end
    end
    squares
  end
end