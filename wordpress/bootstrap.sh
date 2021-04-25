#!/bin/bash
yum update -y
aws s3 sync --delete s3://solution-architect-code-suzoz /var/www/html