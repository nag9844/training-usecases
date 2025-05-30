terraform {  
  backend "s3" {  
    bucket         = "usecases-terraform-state-bucket"  
    key            = "usecase1/statefile.tfstate"  
    region         = "ap-south-1"  
    encrypt        = true  
    use_lockfile   = true
  }  
}