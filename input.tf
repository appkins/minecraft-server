###########
# Location 
###########
variable "location" {
  description = "The location of the resource."
  type        = string
  default     = "centralus"

  validation {
    condition     = can(regex("^(eastus2|centralus)$", var.location))
    error_message = "Invalid location."
  }
}

##########
# Containers 
##########
variable "containers" {
  description = "List of minecraft servers to host as containers."
  type = map(object({
    environment = map(string), port = number
  }))
  default = {
    "mcsurvival" = {
      environment = {
        GAMEMODE   = "survival"
        DIFFICULTY = "hard"
      }
      port = 19132
    }
    "mccreative" = {
      environment = {
        GAMEMODE = "creative"
      }
      port = 19134
    }
  }
}
