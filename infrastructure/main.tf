provider "aws" {
  region = "eu-west-3" # Paris
}

# 1. Ton Bucket S3 (Hébergement du Dashboard)
resource "aws_s3_bucket" "dental_dashboard" {
  bucket = "delphine-health-dashboard-2026-v2" 
}

# 2. Ta Table DynamoDB
resource "aws_dynamodb_table" "pressure_data" {
  name         = "DentalPressureLogs"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "PatientID"
  range_key    = "Timestamp"

  attribute {
    name = "PatientID"
    type = "S"
  }

  attribute {
    name = "Timestamp"
    type = "S"
  }
}

# --- IAM : Le rôle de la Lambda ---
resource "aws_iam_role" "lambda_role" {
  name = "dental_lambda_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

# --- IAM : Permissions combinées (Ecriture + Lecture + Logs) ---
resource "aws_iam_role_policy" "lambda_combined_policy" {
  name = "lambda_dental_policy"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        # ✅ Ajout de dynamodb:Scan pour permettre la lecture des données
        Action   = ["dynamodb:PutItem", "dynamodb:UpdateItem", "dynamodb:Scan"]
        Resource = [aws_dynamodb_table.pressure_data.arn]
      },
      {
        Effect   = "Allow"
        Action   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
        Resource = ["arn:aws:logs:*:*:*"]
      }
    ]
  })
}

# --- ZIP du code Python ---
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "lambda_function.py"
  output_path = "lambda_function.zip"
}

# --- La Fonction Lambda ---
resource "aws_lambda_function" "dental_processor" {
  filename         = "lambda_function.zip"
  function_name    = "DentalDataProcessor"
  role             = aws_iam_role.lambda_role.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.9"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.pressure_data.name
    }
  }
}

# --- URL de la Lambda ---
resource "aws_lambda_function_url" "lambda_url" {
  function_name      = aws_lambda_function.dental_processor.function_name
  authorization_type = "NONE"

  cors {
    allow_origins     = ["*"]
    # ✅ Ajout de "GET" pour que le dashboard puisse lire
    allow_methods     = ["POST", "GET"]
    allow_headers     = ["content-type"]
    expose_headers    = ["*"]
    max_age           = 3600
  }
}

output "lambda_url" {
  value = aws_lambda_function_url.lambda_url.function_url
}

# --- Configuration du Bucket pour l'hébergement Web ---
resource "aws_s3_bucket_website_configuration" "dashboard_config" {
  bucket = aws_s3_bucket.dental_dashboard.id

  index_document {
    suffix = "index.html"
  }
}

# --- Rendre le contenu public (Politique S3) ---
resource "aws_s3_bucket_policy" "public_read" {
  bucket = aws_s3_bucket.dental_dashboard.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.dental_dashboard.arn}/*"
      },
    ]
  })
}

# --- Désactiver le blocage de l'accès public (obligatoire pour S3 moderne) ---
resource "aws_s3_bucket_public_access_block" "allow_public" {
  bucket = aws_s3_bucket.dental_dashboard.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# --- Output de l'URL du site ---
output "dashboard_url" {
  value = "http://${aws_s3_bucket.dental_dashboard.bucket}.s3-website-eu-west-3.amazonaws.com"
}