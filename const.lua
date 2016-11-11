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

return const
