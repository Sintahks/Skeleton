require 'gosu'
require 'rubygems'

class GameWindow < Gosu::Window
	

	def initialize()
		super(600,600, false, 100)
		self.caption = "Othello"
		@board				= Board.new()
		@game 				= Game.new(@board)
		@background_image	= Gosu::Image.new(self, "background.jpg", true)
		@gray_dot			= Gosu::Image.new(self, "grayp.png", true) 
		@black_dot 			= Gosu::Image.new(self, "blackpp.png", true)
		@end_button			= Gosu::Image.new(self, "end_game_button.png", true)
		@skip_button		= Gosu::Image.new(self, "skip.png", true)
		@draw_game			= Gosu::Image.new(self, "draw.png", true)
		@blackwin			= Gosu::Image.new(self, "blackwin.png", true)
		@graywin			= Gosu::Image.new(self, "graywin.png", true)
		@x, @y 				= 0
		
	end
	
	def end_game_bounds?(x, y)
		x < 129 && y < 54
	end 
	
	def skip_bounds?(x,y)
		x> 513 && y < 50 
	end 
	
	def in_bound?(x ,y)
		x_pos = x
		y_pos = y 
		if x_pos < 64 || x_pos > 535 || y_pos < 64 || y_pos > 535
			return false
		else
			return true
		end 
	end 
	
	def to_ind(x, y)
		i = (((x.to_i-64)/59)+(8*(((mouse_y.to_i-64)/59))))
		return i 
	end 
	def to_posn(i)
		x = (((i%8)*60)+62)
		y = (((i/8)*60)+62)
		return [x, y]
	end
	
	def update
		if button_down? Gosu::MsLeft
			#draw_current_ppiece(mouse_x.to_i, mouse_y.to_i)
		end 
	end
	
	
	def draw
		@background_image.draw(0,0,0)
		@board.board_array.each{ |i|
								if @board.board_lay[i] == " X "
									(x,y)= to_posn(i)
									@black_dot.draw(x, y, 2)  
								elsif @board.board_lay[i] == " O "
									(x,y)= to_posn(i)
									@gray_dot.draw(x,y,2)
									
								end
							}
		if @game.end_game?
			case @game.show_winner()
			when " X "
				@blackwin.draw(200, 0, 2)
			when " O "
				@graywin.draw(200, 0, 2)
			when nil
				@draw_game.draw(200,0,2)
			end 
		end 
				
		if $current_player==@game.player1
			@black_dot.draw((mouse_x-20), (mouse_y-20), 2)
		else
			@gray_dot.draw((mouse_x-20), (mouse_y-20), 2)
		end 
		
		@end_button.draw(0,0,2)
		@skip_button.draw(513,0,2)
		
	end 
	
	
	def draw_current_ppiece(x, y)
		@black_dot.draw(x, y, 2)
	end 
		
			
	def needs_cursor?
		true
	end #needs_cursor?
	
	def button_down(id)
		if id == Gosu::KbEscape
			close
		end 
			
		if id == Gosu::MsLeft
			index = to_ind(mouse_x, mouse_y)
			if in_bound?(mouse_x, mouse_y)
				if @game.end_game?()
					nil 
				elsif @board.valid_move?(index)
					@game.make_move(index)
					@game.switch_player()
				end 
			end 
			
			if end_game_bounds?(mouse_x, mouse_y)
				@game.end_game()
			end 
			if skip_bounds?(mouse_x, mouse_y)
				@game.skip()
			end 
		end 

		if id == Gosu::KbSpace
			reset
		end 
	end 
	
	def reset
		@board = Board.new()
		@game = Game.new(@board)
	end 
end  

class Game
		attr_reader :current_player, :player1, :player2
		
	def initialize(board)
		@board 			= 	board#:args[:board] 	: Board.new()
		@player1		=	" X " #args[player1]	: Player.new() 
		@player2		= 	" O " #args[player2]	:Player.new()
		$current_player	=	@player1
		@skipped		= false
		@game_ended		= false 

		
	end
	
	# def get_move(move)
		# #puts "Please make a move. Input Integer"
		# #puts "\n**PRESS CTRL+C TO EXIT THE LOOP**"
		# #move = gets.to_i
		# if @board.valid_move?(move)
			# @board.make_move(move)
		# else 
			# puts "Invalid move. Please try again. \n\n"
			# get_move()
		# end
	# end 
	def make_move(move)
		@board.make_move(move)
		@skipped=false
	end 
	
	def end_game?
		if @game_ended==false 
			return false 
		elsif @end_game
			return true 
		else 
			return true 
		end
	end 
	
	def end_game()
		@game_ended=true 
		show_winner()
	end 
	
	def skip
		if @skipped==false 
			switch_player()
			@skipped = true 
		elsif @skipped==true 
			end_game()
		end 
	end 
	
	def player1_count()
		@board.board.count(@player1)
	end 
	def player2_count()
		@board.board.count(@player2)
	end
	
	def show_winner()
		if player1_count() > player2_count
			return @player1 
		elsif player2_count() > player1_count
			return @player2
		else 
			return nil 
		end
	end 
	
	
	def switch_player()
		if $current_player == @player1
			$current_player = @player2
		else 
			$current_player = @player1
		end 
	end
	
	def add_points()			#<--- Not utilized as of yet. 
	end

end 

class Board 
		attr_reader :board, :skipped, :end_game
	def initialize ()
		@board = [	" . ", " . ", " . ", " . ", " . ", " . ", " . ", " . ",
		
					" . ", " . ", " . ", " . ", " . ", " . " ," . ", " . ",
					
					" . ", " . ", " . ", " . ", " . ", " . ", " . ", " . ",
					
					" . ", " . ", " . ", " X ", " O ", " . ", " . ", " . ",
					
					" . ", " . ", " . ", " O ", " X ", " . ", " . ", " . ",
					
					" . ", " . ", " . ", " . ", " . ", " . ", " . ", " . ",
					
					" . ", " . ", " . ", " . ", " . ", " . ", " . ", " . ",
					
					" . ", " . ", " . ", " . ", " . ", " . ", " . ", " . "]
		@board2 = ["0 " , "1 " , "2 " , "3 " , "4 " , "5 " , "6 " , "7 " ,
		
				   "8 " , "9 " , "10" , "11" , "12" , "13" , "14" , "15" ,
				   
				   "16" , "17" , "18" , "19" , "20" , "21" , "22" , "23" , 
				   
				   "24" , "25" , "26" , "27" , "28" , "29" , "30" , "31" ,
				   
				   "32" , "33" , "34" , "35" , "36" , "37" , "38" , "39" ,
				   
				   "40" , "41" , "42" , "43" , "44" , "45" , "46" , "47" ,
				   
				   "48" , "49" , "50" , "51" , "52" , "53" , "54" , "55" ,
				   
				   "56" , "57" , "58" , "59" , "60" , "61" , "62" , "63" ]
		@board_arr= Array(0..@board.length)
		@board_height	= 8
		@board_width 	= 8
		
	end
	
	def board_array
		@board_arr
	end 
	
	def board_lay
		@board
	end 
	
	def reset()
	end
	
	
	# def draw()
		# #DRAWS THE BOARD 
		
		# n=0
		# n1=0
		# print "THIS IS #{@board_height} #{@board_width}"
		
		# print "\n\n"
		# while n1 < (@board2.length - 1) do
			# print "| #{@board2[n1..(n1 + @board_width - 1)].join(" ")} |\n\n"
			# n1+=@board_height
		# end
		
		# puts "\n\nMake Move/Input appropriately.\n\n\n"
		
		# while n < (@board.length - 1) do
			# print "| #{@board[n..(n + @board_width - 1)].join()} |\n\n"
			# n+=@board_height
		# end		
	# end
	
	
	def valid_move?(move)
		if  in_bounds?(move) && empty_space?(move) && any_converted_pieces?(move)
			return true
		else 
			return false
		end 
	end
	
	def make_move(move)
		@board[move]= $current_player
	end 
	
	def convert_pieces(array)
		array.each{|x| @board[x]=$current_player}
	end 
	
	def passed_left_edge?(move)
		move% @board_width == (@board_width-1)
	end 

	def passed_right_edge?(move)
		move% @board_width==0
	end 
	
	def empty_space?(move)		#CHECKS IF GIVEN INDEX IS AN EMPTY SPACE
		@board[move] == " . "
	end
	
	def count_pieces()
	end

	def in_bounds?(move)
		if move < @board.length && move >= 0
			return true 
		else 
			return false
		end 		
	end 
	
	def conversion?(dir, array)
		right_edges=@board_arr.select{|x| passed_left_edge?(x)}
		left_edges=@board_arr.select{|x| passed_right_edge?(x)}
		top_edges= Array(0..@board_width-1)
		bottom_edges= Array(@board.length-@board_width..@board.length-1)
		
		if array.empty?
			return false
		else 
			case dir
			when "up"
				if top_edges.include?(array.last)
					return false
				elsif empty_space?(array.last-@board_height)
					return false 
				else
					return true
				end
			when "down"
				if bottom_edges.include?(array.last)
					return false
				elsif empty_space?(array.last+@board_height)
					return false
				else
					return true
				end
			when "right"
				if right_edges.include?(array.last)
					return false
				elsif empty_space?(array.last+1)
					return false
				else
					return true
				end 
			when "left"
				if left_edges.include?(array.last)
					return false
				elsif empty_space?(array.last-1)
					return false
				else
					return true 
				end 
			
			
			when "RUD"
				if top_edges.include?(array.last)|| right_edges.include?(array.last)
					return false
				elsif empty_space?(array.last+1-@board_height)
					return false
				else
					return true
				end
			 
			
			when "RDD"
				if bottom_edges.include?(array.last) || right_edges.include?(array.last)
					return false
				elsif empty_space?(array.last+1+@board_height)
					return false
				else 
					return true
				end 
			 
			
			when "LDD"
				if bottom_edges.include?(array.last)|| left_edges.include?(array.last)
					return false
				elsif empty_space?(array.last-1+@board_height)
					return false
				else 
					return true 
				end 
			
			
			when "LUD"
				if top_edges.include?(array.last) || left_edges.include?(array.last)
					return false
				elsif empty_space?(array.last-1-@board_height)
					return false
				else 
					return true
				end 
			end 
		end 
	end 
	
		def check_RUpDiag(move)
			nxt_spc= ((move-@board_height)+1)
			array= []
			until passed_right_edge?(nxt_spc)|| empty_space?(nxt_spc) || cp_piece?(nxt_spc) || (not in_bounds?(nxt_spc)) do
				array.push(nxt_spc)
				nxt_spc-=(@board_height-1)
			end
			return array
		end
		
		def check_RDownDiag(move)
			nxt_spc= ((move+@board_height)+1)
			array= []
			until passed_right_edge?(nxt_spc)|| empty_space?(nxt_spc) || cp_piece?(nxt_spc) || (not in_bounds?(nxt_spc)) do
				array.push(nxt_spc)
				nxt_spc+=(@board_height+1)
			end
			return array
		end
		
		def check_LUpDiag(move)
			nxt_spc= ((move-@board_height)-1)
			array=[]
			until passed_left_edge?(nxt_spc)|| empty_space?(nxt_spc)|| cp_piece?(nxt_spc) || (not in_bounds?(nxt_spc)) do
				array.push(nxt_spc)
				nxt_spc-=(@board_height+1)
			end
			return array
		end 
		
		def check_LDownDiag(move)
			nxt_spc=((move+@board_height)-1)
			array = []
			until passed_left_edge?(nxt_spc) || empty_space?(nxt_spc)|| cp_piece?(nxt_spc)|| (not in_bounds?(nxt_spc)) do
				array.push(nxt_spc)
				nxt_spc+=(@board_height-1)
			end
			return array
		end
		
		
		def check_right(move)
		nxt_spc= move+1
		array=[]
		until passed_right_edge?(nxt_spc) || empty_space?(nxt_spc) || cp_piece?(nxt_spc) do
			array.push(nxt_spc)
			nxt_spc+=1
		end
		return array
		end 

	def check_left(move)
		nxt_spc= move-1
		array=[]
		until passed_left_edge?(nxt_spc) || empty_space?(nxt_spc) || cp_piece?(nxt_spc) do
			array.push(nxt_spc)
			nxt_spc-=1
		end
		return array
	end 

	def check_up(move)
		nxt_spc= (move-@board_height)
		array= []
		until (not in_bounds?(nxt_spc))|| empty_space?(nxt_spc) || cp_piece?(nxt_spc) do
			array.push(nxt_spc)
			nxt_spc-=@board_height 
		end
		return array
	end

	def check_down(move)
		nxt_spc=(move+@board_height)
		array = []
		until (not in_bounds?(nxt_spc))|| empty_space?(nxt_spc)|| cp_piece?(nxt_spc) do 
			array.push(nxt_spc)
			nxt_spc+=@board_height
		end
		return array
	end 
	
 	def cp_piece?(move)
		if move==nil
			return false
		else 
			@board[move]== $current_player
		end 
	end
			
	def any_converted_pieces?(move)
		 right		=	["right", check_right(move)]
		 left		=	["left", check_left(move)]
		 up			=	["up", check_up(move)]
		 down		=	["down", check_down(move)]
		 rud		=	["RUD", check_RUpDiag(move)]
		 rdd		=	["RDD", check_RDownDiag(move)]
		 lud		=	["LUD", check_LUpDiag(move)]
		 ldd		=	["LDD", check_LDownDiag(move)]
		 directions	= 	[right, left, up, down, rud, rdd, lud, ldd]
		 valid_move	= 	false
		 directions.each do |dir, arr|
			if conversion?(dir, arr)
				convert_pieces(arr)
				valid_move= true
			end 
		 end
		return valid_move
	end 
	
end 

game=GameWindow.new
game.show