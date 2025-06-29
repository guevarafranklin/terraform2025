# Data source to get the latest Amazon Linux 2 AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Security Group for LAMP server
resource "aws_security_group" "lamp_sg" {
  name_prefix = "lamp-sg-"
  description = "Security group for LAMP server"

  # SSH access
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "SSH access"
  }

  # HTTP access
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP access"
  }

  # HTTPS access
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTPS access"
  }

  # All outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "All outbound traffic"
  }

  tags = {
    Name        = "LAMP-SecurityGroup"
    Environment = "Development"
  }
}

# Key Pair (you'll need to create this manually or provide your own)
resource "aws_key_pair" "lamp_key" {
  key_name   = "lamp-server-key"
  public_key = file("~/.ssh/id_rsa.pub") # Make sure you have this file or change the path
}

# EC2 Instance for LAMP server
resource "aws_instance" "lamp_server" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t2.micro" # Free tier eligible
  key_name               = aws_key_pair.lamp_key.key_name
  vpc_security_group_ids = [aws_security_group.lamp_sg.id]

  # User data script to install LAMP stack
  user_data = <<-EOF
    #!/bin/bash
    # Update system
    yum update -y
    
    # Install Apache (httpd)
    yum install -y httpd
    systemctl start httpd
    systemctl enable httpd
    
    # Install MySQL (MariaDB)
    yum install -y mariadb-server
    systemctl start mariadb
    systemctl enable mariadb
    
    # Install PHP and extensions
    yum install -y php php-mysql php-gd php-xml php-mbstring
    
    # Restart Apache to load PHP
    systemctl restart httpd
    
    # Create a simple PHP info page
    cat > /var/www/html/info.php << 'EOL'
<?php
phpinfo();
?>
EOL
    
    # Create a simple index.html
    cat > /var/www/html/index.html << 'EOL'
<!DOCTYPE html>
<html>
<head>
    <title>LAMP Server Ready</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; }
        .container { max-width: 800px; margin: 0 auto; }
        .status { background: #d4edda; padding: 20px; border-radius: 5px; }
    </style>
</head>
<body>
    <div class="container">
        <h1>🚀 LAMP Server is Ready!</h1>
        <div class="status">
            <h2>Server Components:</h2>
            <ul>
                <li>✅ Linux (Amazon Linux 2)</li>
                <li>✅ Apache HTTP Server</li>
                <li>✅ MySQL (MariaDB)</li>
                <li>✅ PHP</li>
            </ul>
            <p><strong>Next steps:</strong></p>
            <ul>
                <li>Visit <a href="/info.php">info.php</a> to see PHP configuration</li>
                <li>Secure MySQL with: <code>sudo mysql_secure_installation</code></li>
                <li>Upload your web applications to <code>/var/www/html/</code></li>
            </ul>
        </div>
    </div>
</body>
</html>
EOL
    
    # Set proper permissions
    chown -R apache:apache /var/www/html/
    chmod -R 755 /var/www/html/
    
    # Configure firewall (if needed)
    # firewall-cmd --permanent --add-service=http
    # firewall-cmd --permanent --add-service=https
    # firewall-cmd --reload
  EOF

  # Storage configuration (free tier gets 30GB)
  root_block_device {
    volume_type = "gp2"
    volume_size = 20 # GB - within free tier limits
    encrypted   = true
  }

  tags = {
    Name        = "LAMP-Server"
    Environment = "Development"
    Purpose     = "Web Development"
    OS          = "Amazon Linux 2"
  }
}

# Elastic IP (optional - for consistent public IP)
resource "aws_eip" "lamp_eip" {
  instance = aws_instance.lamp_server.id
  domain   = "vpc"

  tags = {
    Name = "LAMP-Server-EIP"
  }
}