#!/usr/bin/env python3

import os
import shutil
import boto3
import certbot.main

# Let’s Encrypt acme-v02 server that supports wildcard certificates
CERTBOT_SERVER = 'https://acme-v02.api.letsencrypt.org/directory'

# Temp dir of Lambda runtime
CERTBOT_DIR = '/tmp/certbot'

aws_region: str = os.getenv('REGION')


def rm_tmp_dir():
    if os.path.exists(CERTBOT_DIR):
        try:
            shutil.rmtree(CERTBOT_DIR)
        except NotADirectoryError:
            os.remove(CERTBOT_DIR)


def obtain_cert(email, domain):
    certbot_args = [
        # Override directory paths so script doesn't have to be run as root
        '--config-dir', CERTBOT_DIR,
        '--work-dir', CERTBOT_DIR,
        '--logs-dir', CERTBOT_DIR,

        # Obtain a cert but don't install it
        'certonly',

        # Run in non-interactive mode
        '--non-interactive',

        # Agree to the terms of service
        '--agree-tos',

        # Email of domain administrators
        '--email', email,

        # Use dns challenge with route53
        '--dns-route53',
        '--preferred-challenges', 'dns-01',

        # Use this server instead of default acme-v01
        '--server', CERTBOT_SERVER,

        # Domains to provision certs for (comma separated)
        '--domains', domain,
    ]
    return certbot.main.main(certbot_args)


# /tmp/certbot
# ├── live
# │   └── [domain]
# │       ├── README
# │       ├── cert.pem
# │       ├── chain.pem
# │       ├── fullchain.pem
# │       └── privkey.pem
def upload_cert(domain, s3_bucket):
    client = boto3.client('s3', aws_region)
    cert_dir = os.path.join(CERTBOT_DIR, 'live')
    domain_dir = os.path.join(cert_dir, domain)
    filenames = os.listdir(domain_dir)
    for filename in filenames:
        filepath = os.path.join(domain_dir, filename)
        s3_object_key = f'{domain}/{filename}'
        print(f'Uploading: {filepath} => s3://{s3_bucket}/{s3_object_key}')
        client.upload_file(filepath, s3_bucket, s3_object_key)


def guarded_handler(event, context):
    emails_csv: str = os.getenv('EMAILS')
    domains_csv: str = os.getenv('DOMAINS')
    s3_bucket_csv: str = os.getenv('BUCKETS')
    emails: list[str] = emails_csv.split(',')
    domains: list[str] = domains_csv.split(',')
    buckets: list[str] = s3_bucket_csv.split(',')
    
    for email, domain, bucket in zip(emails, domains, buckets):
        obtain_cert(email, domain)
        upload_cert(domain.lstrip('*.'), bucket)

    return 'Certificates obtained and uploaded successfully.'


def lambda_handler(event, context):
    try:
        rm_tmp_dir()
        return guarded_handler(event, context)
    finally:
        rm_tmp_dir()