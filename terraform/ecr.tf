resource "aws_ecr_repository" "ngo_service" {
  name         = "solidarytech/ngo-service"
  force_delete = true

  tags = {
    Project     = "SolidaryTech"
    Environment = "Production"
    CostCenter  = "NGO-Core"
  }
}

resource "aws_ecr_repository" "donation_service" {
  name         = "solidarytech/donation-service"
  force_delete = true

  tags = {
    Project     = "SolidaryTech"
    Environment = "Production"
    CostCenter  = "NGO-Core"
  }
}

resource "aws_ecr_repository" "volunteer_service" {
  name         = "solidarytech/volunteer-service"
  force_delete = true

  tags = {
    Project     = "SolidaryTech"
    Environment = "Production"
    CostCenter  = "NGO-Core"
  }
}