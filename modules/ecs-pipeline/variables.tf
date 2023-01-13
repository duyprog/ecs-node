variable "repo_name" {
  description = "Name of CodeCommit Repo"
  type        = string
}

variable "build_project" {
  type        = string
  description = "Name of build project"
}

variable "branch_name" {
  type        = string
  description = "Branch name for cicd"
}
