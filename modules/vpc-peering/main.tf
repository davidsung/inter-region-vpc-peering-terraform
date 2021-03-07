data "aws_caller_identity" "peer" {
  provider = aws.peer
}

resource "aws_vpc_peering_connection" "vpc_peering_connection" {
  provider = aws.local
  vpc_id = var.local_vpc_id
  peer_vpc_id = var.peer_vpc_id
  peer_region = var.peer_region
  peer_owner_id = data.aws_caller_identity.peer.id

  tags = {
    Side = "Requester"
  }
}

resource "aws_vpc_peering_connection_accepter" "vpc_peering_connection_accepter" {
  provider = aws.peer
  vpc_peering_connection_id = aws_vpc_peering_connection.vpc_peering_connection.id
  auto_accept = true

  tags = {
    Side = "Accepter"
  }
}

resource "aws_vpc_peering_connection_options" "local_vpc_peering_connection_options" {
  provider = aws.local
  vpc_peering_connection_id = aws_vpc_peering_connection_accepter.vpc_peering_connection_accepter.id

  requester {
    allow_classic_link_to_remote_vpc = var.local_allow_classic_link_to_remote_vpc
    allow_vpc_to_remote_classic_link = var.local_allow_vpc_to_remote_classic_link
    allow_remote_vpc_dns_resolution = var.local_allow_remote_vpc_dns_resolution
  }
}

resource "aws_vpc_peering_connection_options" "peer_vpc_peering_connection_options" {
  provider = aws.peer
  vpc_peering_connection_id = aws_vpc_peering_connection_accepter.vpc_peering_connection_accepter.id

  accepter {
    allow_classic_link_to_remote_vpc = var.peer_allow_classic_link_to_remote_vpc
    allow_vpc_to_remote_classic_link = var.peer_allow_vpc_to_remote_classic_link
    allow_remote_vpc_dns_resolution = var.peer_allow_remote_vpc_dns_resolution
  }
}

resource "aws_route" "peer_route_in_local" {
  provider               = aws.local
  count                  = length(var.local_route_table_ids)
  route_table_id         = var.local_route_table_ids[count.index]
  destination_cidr_block = var.peer_vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.vpc_peering_connection.id
  depends_on             = [aws_vpc_peering_connection_accepter.vpc_peering_connection_accepter]
}

resource "aws_route" "local_route_in_peer" {
  provider               = aws.peer
  count                  = length(var.peer_route_table_ids)
  route_table_id         = var.peer_route_table_ids[count.index]
  destination_cidr_block = var.local_vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.vpc_peering_connection.id
  depends_on             = [aws_vpc_peering_connection_accepter.vpc_peering_connection_accepter]
}
