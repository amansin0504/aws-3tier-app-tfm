variable region {
    default = "us-west-1"
}

variable az1 {
    default = "us-west-1a"
}

variable az2 {
    default = "us-west-1c"
}

variable user {
    default = "wpuser"
}

variable password {
    type = string
    description = "SQL db Password"
    default = "wpuser123$"
}

variable dbname {
    default = "saferdsdb"
}

variable "images" {
  type    = map(string)
  default = {
    "us-east-1" = "ami-00e87074e52e6c9f9"
    "us-west-1" = "ami-08d2d8b00f270d03b"
    "us-east-2" = "ami-00f8e2c955f7ffa9b"
    "us-west-2" = "ami-0686851c4e7b1a8e1"
  }
}

variable "keyname" {
    default = "california"
}

variable "csws3arn" {
    type    = string
    default = "arn:aws:s3:::cswvpcflowbucket"
}