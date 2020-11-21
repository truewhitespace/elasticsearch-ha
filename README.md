# elasticsearch-ha

# Development
Salt & Pepper the `config.sh` file with the correct values.  Then run `./build-and-test.sh` to create a candidate AMI
then spin up an instance of the AMI via Terraform.

The IDs of generated AMIs will be stored in `manifest.json` as per format of the (Manifest post-processor)[https://www.packer.io/docs/post-processors/manifest]

## Assumptions

You must have a valid AWS environment setup however you choose.  The environment variable `AWS_DEFAULT_REGION` must also
be set to the target region you are building against.
