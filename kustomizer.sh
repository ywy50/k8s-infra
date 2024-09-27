#!/bin/bash

# Function to create kustomization.yaml in the given directory
create_kustomization() {
  local dir=$1

  # Find subdirectories
  subdirs=$(find "$dir" -mindepth 1 -maxdepth 1 -type d)

  # Find .yaml files
  yamls=$(find "$dir" -mindepth 1 -maxdepth 1 -type f -name "*.yaml" ! -name "kustomization.yaml")

  # Skip if no subdirectories or .yaml files are found
  if [ -z "$subdirs" ] && [ -z "$yamls" ]; then
    return
  fi

  # Create kustomization.yaml file
  cat <<EOF > "$dir/kustomization.yaml"
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
EOF

  # Add each subdirectory to the kustomization.yaml as a resource
  for subdir in $subdirs; do
    echo "  - $(basename "$subdir")" >> "$dir/kustomization.yaml"
  done

  # Add each .yaml file to the kustomization.yaml as a resource
  for yaml in $yamls; do
    echo "  - $(basename "$yaml")" >> "$dir/kustomization.yaml"
  done
}

# Define the main directory
MAIN_DIR=$1

# Recursively create kustomization.yaml files
find "$MAIN_DIR" -type d | while read -r dir; do
  create_kustomization "$dir"
done

echo "kustomization.yaml files created successfully!"
