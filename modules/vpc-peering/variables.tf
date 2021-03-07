variable "local_vpc_id" {
  type = string
}

variable "local_vpc_cidr" {
  type = string
}

variable "local_route_table_ids" {
  type = list(string)
}

variable "local_allow_classic_link_to_remote_vpc" {
  type = bool
  default = false
}

variable "local_allow_vpc_to_remote_classic_link" {
  type = bool
  default = false
}

variable "local_allow_remote_vpc_dns_resolution" {
  type = bool
  default = true
}

variable "peer_vpc_id" {
  type = string
}

variable "peer_vpc_cidr" {
  type = string
}

variable "peer_region" {
  type = string
}

variable "peer_route_table_ids" {
  type = list(string)
}

variable "peer_allow_classic_link_to_remote_vpc" {
  type = bool
  default = false
}

variable "peer_allow_vpc_to_remote_classic_link" {
  type = bool
  default = false
}

variable "peer_allow_remote_vpc_dns_resolution" {
  type = bool
  default = true
}
