local const = {}

-- window constants
const.width = 640
const.height = 480
const.title = "Scooter Rage 0.1.0"

-- key status enum
const.keyup = 0
const.keydown = 1
const.keyrepeat = 2

-- supported keys
const.keys =
   {
      ["retour"] = "escape",
      ["avancer"] = "right",
      ["haut"] = "up",
      ["bas"] = "down",
      ["sauter"] = "space",
      ["tricks"] = "d",
      ["critique"] = "c",
      ["select"] = "return"
   }

-- animation constants
const.fps = 6
const.delay = 1 / const.fps

return const
