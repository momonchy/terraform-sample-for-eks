variable "profile" {
  type        = string
  default     = "aws_profile_name"
  description = "AWSプロファイル名を指定"
}

variable "inbound_ips" {
  type = map(object({
    ip      = list(string)
    comment = string
  }))
  default = {
    sample_1 = {
      ip = [
        "123.123.123.123/32"
      ]
      comment = "The sample IPs."
    },
    sample_2 = {
      ip = [
        "234.234.234.234/32"
      ]
      comment = "The sample IPs."
    }
  }
  description = "インバウンドIPを指定"
}