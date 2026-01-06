#!/usr/bin/env python3
import sys
import tempfile
import shutil
import os
from pathlib import Path

import ansible_runner

if len(sys.argv) != 2:
    print("Usage: python test.py <target_ip>")
    sys.exit(1)

target_ip = sys.argv[1]
playbook_path = os.path.abspath("../ansible/test.yml")

# Create temporary private_data_dir (required by ansible-runner)
private_data_dir = Path(tempfile.mkdtemp(prefix="ansible_runner_"))
try:
    # Fix: proper INI inventory (no trailing comma)
    inventory_content = f"""[all]
{target_ip} ansible_host={target_ip}
"""
    inventory_file = private_data_dir / "inventory"
    inventory_file.write_text(inventory_content)

    # Run ansible-runner with all your CLI flags as parameters
    r = ansible_runner.run(
        private_data_dir=str(private_data_dir),
        playbook=playbook_path,
        inventory=str(inventory_file),
        extravars={
            "ansible_connection": "ssh",
            "ansible_shell_type": "powershell",
            "ansible_ssh_args": (
                "-o StrictHostKeyChecking=no "
                "-o PreferredAuthentications=password "
                "-o PubkeyAuthentication=no "
                "-o HostKeyAlgorithms=+ssh-rsa "
                "-o PubkeyAcceptedKeyTypes=ssh-rsa "
                "-o UserKnownHostsFile=/dev/null"
            ),
            "ansible_ssh_user": "admin",
            "ansible_ssh_pass": "password",
            "ansible_become_pass": "password",
            "ansible_host_key_checking": False,
            "ansible_ssh_pipelining": False,
        },
        envvars={
            "ANSIBLE_HOST_KEY_CHECKING": "False",
        },
        forks=1,
        verbosity=3,
    )

    print(f"Status: {r.status} (RC: {r.rc})")
    print(f"Artifacts in: {private_data_dir}")

finally:
    pass  # Keep artifacts for inspection
