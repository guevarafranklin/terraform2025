 resource "local_file" "products" {
   content  = "This is a local file created by Terraform. This is a list for the next month's products.\nProduct 1\nProduct 2\nProduct 3"
   filename = "${path.module}/products.txt"
   
 }