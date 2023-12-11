resource "terraform_data" "known_data" {
  input = "1"
}

module "docs" {
  source          = "./modules/docs"
  depends_on = [ terraform_data.known_data ]
}






