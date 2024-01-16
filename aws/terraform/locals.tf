locals {
  group_ip_list = ["78.121.121.75/32", "90.2.109.5/32"]
  group         = "b3-gr3"
  tags = {
    Name = local.group
  }
}
