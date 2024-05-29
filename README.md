
# AYA Node Packer

This Packer configuration will provision an image to run a full AYA node. It is currently based on the [simple join guide](https://github.com/worldmobilegroup/aya-node/blob/main/docs/guide_join_devnet_simple.md).

To make your server validate blocks, provision a server with this image and continue from step 5 of the guide. Note: This image does not set up a firewall, as it is recommended to configure this with your provider.

The username is statically set to `aya`. If you wish to change this, ensure that all relevant files are updated accordingly.

## Building the Image

Navigate to the directory of your provider (e.g., `gcp`) and run:
```sh
packer build -var 'gcp_project_id=YOUR_GCP_PROJECT_ID' aya-base-image.pkr.hcl
```

The image is stored in the eu region by default. You can add the gcp zone to store it somewhere else.
```sh
packer build -var 'gcp_project_id=YOUR_GCP_PROJECT_ID' -var 'gcp_zone=YOUR_GCP_ZONE' aya-base-image.pkr.hcl
```


## Prerequisites

You should have Packer installed and configured with your provider. For installation instructions, refer to the [Packer documentation](https://developer.hashicorp.com/packer/tutorials/docker-get-started/get-started-install-cli).

## Using the Ansible Role Directly
If you prefer to use Ansible directly to set up the AYA node on your server without using Packer, you can use the aya_node role. This approach is useful for users who want to integrate the AYA node setup into their existing Ansible-managed infrastructure.

See the ansible directory README for more info.


## Connect with Us

If you like this contribution to the World Mobile community, give us a follow on [Twitter](https://twitter.com/4thechain). You can also visit our [website](https://4thechain.com/) for more information about 4TheChain.

Feel free to reach out if you'd like us to create configurations for other providers like AWS or if you have any feature requests. You can also request features or report issues via [GitHub issues](https://github.com/4thechain/aya-node-image/issues).
