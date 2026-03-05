#!/usr/bin/env python3
import os
import re
import sys

# Paths
REPO_ROOT = "/Users/snowdream/Workspace/Uniloader"
OS_REF_PATH = os.path.join(REPO_ROOT, "docs/OS_REFERENCE.md")
CI_TEMPLATE_PATH = os.path.join(REPO_ROOT, ".github/workflows/ci.yml")
WORKFLOWS_DIR = os.path.join(REPO_ROOT, ".github/workflows")

# 1. Read OS Reference to extract valid Linux OSes
# We filter out Windows, BSD, Solaris, etc., keeping Docker-friendly Linux distros.
allowed_families = [
    "RedHat",
    "Debian",
    "Alpine",
    "Suse",
    "Archlinux",
    "Mandrake",
    "Altlinux",
    "Void",
    "ClearLinux",
    "Solus",
    "OpenWrt",
    "Linux",
]
os_list = set()

try:
    with open(OS_REF_PATH, "r") as f:
        for line in f:
            if not line.startswith("|"):
                continue
            parts = [p.strip() for p in line.split("|")]
            if len(parts) < 3:
                continue

            family_raw = parts[1].replace("**", "")
            if family_raw not in allowed_families:
                continue

            distro_raw = parts[2].replace("`", "")
            # Some entries have multiple names like "Kylin / KylinOS", split them
            for d in map(str.strip, distro_raw.split("/")):
                # Skip generic names or names with spaces that aren't good docker images
                d_clean = d.lower().replace(" ", "")
                if d_clean and d_clean not in ["linux", "redhat", "debian", "suse"]:
                    os_list.add(d_clean)
except Exception as e:
    print(f"Error reading OS Reference: {e}")
    sys.exit(1)

# Ensure "alpine" is explicitly there
os_list.add("alpine")
os_list = sorted(list(os_list))

print(f"Found {len(os_list)} valid OS targets for CI generation.")

# 2. Read CI Template
try:
    with open(CI_TEMPLATE_PATH, "r") as f:
        ci_template = f.read()
except Exception as e:
    print(f"Error reading CI template: {e}")
    sys.exit(1)

# 3. Generate individual YAML files
generated_count = 0
for os_name in os_list:
    # Skip ci.yml itself just in case
    if os_name == "ci":
        continue

    workflow_content = ci_template

    # Modify Name
    workflow_content = workflow_content.replace("name: CI", f"name: CI ({os_name.capitalize()})")

    # We need to modify the integration test step to run a specific container and test against it.
    # The current ci.yml says:
    #  docker compose up -d
    #  ansible-playbook -i inventory/docker.yml playbooks/test.yml
    # We will replace this with spinning up a basic container of that OS.
    # NOTE: Since many esoteric OS names might not have an official docker image exactly
    # matching the name, we use the name directly assuming it works, or fallback to a standard pattern.

    test_step_replacement = (
        f"      - name: Start Docker Container for {os_name}\n"
        f"        run: |\n"
        f"          # Try to pull and run the image, if it fails, the workflow just fails\n"
        f"          # (which is expected for unsupported ones natively)\n"
        f"          docker run -d --name uls_{os_name} --privileged {os_name} \\\n"
        f'            sleep 86400 || echo "WARNING: Image {os_name} not found or failed to start."\n\n'
        f"          # Create a dynamic inventory file for this run\n"
        f"          cat << 'INV' > inventory/dynamic_docker.yml\n"
        f"          all:\n"
        f"            vars:\n"
        f"              become_enabled: false\n"
        f"            hosts:\n"
        f"              {os_name}:\n"
        f"                ansible_host: uls_{os_name}\n"
        f'                ansible_connection: "docker"\n'
        f'                node_tags: ["open", "container", "docker_container"]\n'
        f"          INV\n\n"
        f"      - name: Run ansible-playbook test\n"
        f"        run: |\n"
        f"          source .venv/bin/activate\n"
        f"          ansible-playbook -i inventory/dynamic_docker.yml playbooks/test.yml\n\n"
        f"      - name: Cleanup Docker Containers\n"
        f"        if: always()\n"
        f"        run: |\n"
        f"          docker rm -f uls_{os_name} || true\n"
    )

    # Replace the existing Docker start/test/cleanup block
    # This regex looks for the 'Start Docker Containers' step and everything after it until the end.
    workflow_content = re.sub(
        r"      - name: Start Docker Containers.*Cleanup Docker Containers\n.*docker compose down\n",
        test_step_replacement,
        workflow_content,
        flags=re.DOTALL,
    )

    out_file = os.path.join(WORKFLOWS_DIR, f"{os_name}.yml")
    with open(out_file, "w") as f:
        f.write(workflow_content)
    generated_count += 1

print(f"Successfully generated {generated_count} CI workflows in .github/workflows/")
