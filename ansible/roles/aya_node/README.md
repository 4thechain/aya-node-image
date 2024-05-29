# Ansible Role: Aya Node

An Ansible role to install and configure the AYA node on a server.

## Requirements

- Ansible 2.9+
- Supported platforms:
    - Ubuntu 22.04 (Jammy)

## Role Variables

The following variables can be customized in your playbook:

```yaml
# Path to the split_session_key script
split_session_key_script_path: /home/aya/utils/session_key_tools/split_session_key.sh

# AYA node version to download
aya_node_version: devnet-v.0.3.0

# URL for the AYA node binary
aya_node_binary_url: "https://github.com/worldmobilegroup/aya-node/releases/download/{{ aya_node_version }}/aya-node"

# URL for the AYA node chainspec file
aya_node_chainspec_url: "https://github.com/worldmobilegroup/aya-node/releases/download/{{ aya_node_version }}/wm-devnet-chainspec.json"
```

## Dependencies

None.

## Example Playbook

Here's an example playbook that uses this role:

```yaml
---
- name: Install and configure AYA node
  hosts: all
  become: yes
  roles:
    - role: aya_node
      vars:
      split_session_key_script_path: /home/aya/utils/session_key_tools/split_session_key.sh
      aya_node_version: devnet-v.0.3.0
```

## License

MIT

## Author Information

This role was created by Kris Barnhoorn, 4TheChain.

## Contributing

If you find this role useful and would like to contribute, please fork the repository and submit a pull request. For any issues or feature requests, please open an issue on GitHub.
