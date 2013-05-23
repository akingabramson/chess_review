class Player
  COL_HASH = {a: 0, b: 1, c: 2, d: 3, e: 4, f: 5, g: 6, h: 7}

  def initialize(board)
    @board = board
  end


  def turn(color)

    #ASH: Try raising exceptions here as well.
    while true
      puts "Choose the piece to move"
      piece = get_input
      unless !@board[*piece].nil? && @board[*piece].color == color
        puts "Invalid entry"
        next
      end
      puts "Choose the destination"
      destination = get_input

      return [piece, destination]
    end
  end


  def translate_move(row, column)

    [row - 1, COL_HASH[column]]
  end

  def get_input
    while true
      puts "enter the column (letters a - h)"
      piece_col = gets.chomp
      unless piece_col.match(/[a-h]/)
        "Invalid entry"
        next
      end
      puts "enter the row (1 - 8)"
      piece_row = gets.chomp.to_i
      unless piece_row.between?(1,8)
        "Invalid entry"
        next
      end
      return translate_move(piece_row, piece_col.to_sym)
    end
  end

end