CHESS_CONSTANT = {
 PATH = "files/images/Chess/",
 CHESS_URL = 
{
	"King",
	"Queen", 
	"Rook",
	"Bishop",
	"Knight",
	"Pawn",
},

 dim = {guiGetScreenSize()},
 WIDTH = dim[1]*0.4,
 HEIGHT = WIDTH,
 START_X = dim[1]*0.5 - WIDTH*0.5,
 START_Y = dim[2]*0.5 - HEIGHT*0.5,
 TILE_SIZE = WIDTH/8,
 TILE_COLORS = 
{
	tocolor(150,150,150,255),
	tocolor(50, 50, 50,255),
},
 PIECE_COLORS = 
{
	tocolor(255,255,255,255),
	tocolor(0,0,0,255),

},
 MARK_COLOR = tocolor(0,200,200,50),
 ERROR_MARK_COLOR = tocolor(200,0,0,0),
 NEXT_STEP_COLOR = tocolor(0,200,0,50),
 }