extends AnimatedSprite2D

@export var banner_color :Constants.BannerColor = Constants.BannerColor.RED

func _ready():
	play(fetch_animation())
	
func change_color(new_color :Constants.BannerColor):
	banner_color = new_color
	animation = fetch_animation()

func fetch_animation():
	match(banner_color):
		Constants.BannerColor.RED:
			return "red"
		Constants.BannerColor.ORANGE:
			return "orange"
		Constants.BannerColor.YELLOW:
			return "yellow"
		Constants.BannerColor.GREEN:
			return "green"
		Constants.BannerColor.BLUE:
			return "blue"
		Constants.BannerColor.PURPLE:
			return "purple"
		Constants.BannerColor.BLACK:
			return "black"
		Constants.BannerColor.WHITE:
			return "white"
