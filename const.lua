local const = {}

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
      ["play"] = "return"
   }

-- animation constants
const.fps = 6
const.delay = 1 / const.fps

return const
