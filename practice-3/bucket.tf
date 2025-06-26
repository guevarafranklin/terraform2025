resource "aws_s3_bucket" "my_bucket" {
  count  = 5
  bucket = "ringmehere-${random_string.sufijo[count.index].id}"

  tags = {
    "admin" = "admin"
  }
}