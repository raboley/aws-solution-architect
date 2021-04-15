resource "aws_flow_log" "i" {
  iam_role_arn    = aws_iam_role.i.arn
  log_destination = aws_cloudwatch_log_group.i.arn
  traffic_type    = "ALL"
  vpc_id          = aws_vpc.i.id
}

resource "aws_cloudwatch_log_group" "i" {
  name = var.vpc_name
}

resource "aws_iam_role" "i" {
  name = var.vpc_name

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "vpc-flow-logs.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "i" {
  name = var.vpc_name
  role = aws_iam_role.i.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}