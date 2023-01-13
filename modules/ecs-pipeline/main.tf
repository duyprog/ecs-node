data "aws_iam_role" "codepipeline" {
  name = "codepipeline-role"
}

resource "aws_iam_role" "codebuild-role" {
  name = "codebuild-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "codebuild.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "codebuild-policy" {
  role = aws_iam_role.codebuild-role.arn
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = ["gitcommit:GitPull"]
        Effect = "Allow"
        Resource = "*"
      },
      {
        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",    
          "ecr:BatchGetImage",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:GetAuthorizationToken"
        ]
        Effect = "Allow"
        Resource = "*"
      },
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents" 
        ]
        Effect = "Allow"
        Resource = "*"
      },
      {
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:GetBucketAcl",
          "s3:GetBucketLocation"
        ]
        Effect = "Allow"
        Resource = "*"
      }
    ]
  })
}

# resource "aws_codecommit_repository" "repo" {
#   repository_name = var.repo_name
# }

resource "aws_codebuild_project" "codebuild-project" {
  name = var.build_project
  service_role = aws_iam_role.codebuild-role.arn

  artifacts {
    type = "NO_ARTIFACTS"
  }

  source {
    type = "CODECOMMIT"
    location = aws_codecommit_repository.repo.clone_url_http
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image = "aws/codebuild/standard:1.0"
    type = "LINUX_CONTAINER"
    privileged_mode = true
  }
}

resource "aws_s3_bucket" "bucket-artifact" {
  bucket = "artifactory-bucket"
  acl = "private"
}

resource "aws_codepipeline" "pipeline" {
  name = "pipeline"
  role_arn = data.aws_iam_role.codepipeline.arn

  artifact_store {
    location = aws_s3_bucket.bucket-artifact.bucket
    type = "S3"
  }

  # Source 
  stage {
    name = "Source"
    action {
      name = "Source"
      category = "Source"
      owner = "AWS"
      provider = "CodeCommit"
      version = "1"
      output_artifacts = ["source_output"]
      
      configuration = {
        RepositoryName = var.repo_name
        BranchName = var.branch_name
      }
    }
  }
  # Build 
  stage {
    name = "BUILD"
    action {
      name = "Build"
      category = "Buiild"
      owner = "AWS"
      provider = "CodeBuild" 
      version = 1
      input_artifacts = ["source_output"]
      output_artifacts = ["build_output"]

      configuration = {
        ProjectName = aws_codebuild
      }
    }
  }
  
}