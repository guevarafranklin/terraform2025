 resource "local_file" "products" {
  count = 5
   content  = "This is a local file created by Terraform. This is a list for the next month's products.\nProduct 1\nProduct 2\nProduct 3"
   filename = "${path.module}/products-${random_string.sufijo[count.index].id}.txt"
   
 }

