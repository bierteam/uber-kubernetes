#!/usr/bin/env bash
# Convert CRDs into the strict JSON schemas kubeconform expects, under hack/schemas/.
#
# hack/validate-manifests.sh checks hack/schemas/ before the datreeio CRDs-catalog.
# Use this for CRDs whose catalog schema lags behind the chart that is deployed,
# and rerun it when that chart is bumped. Mirrors kubeconform's openapi2jsonschema:
# objects are closed unless they preserve unknown fields, and int-or-string
# becomes a oneOf.
#
# Usage:  hack/gen-crd-schema.sh <crd.yaml> [...]
# e.g.    tar -xzOf argocd-managed/gpu-operator/charts/gpu-operator-*.tgz \
#           gpu-operator/crds/nvidia.com_clusterpolicies.yaml > /tmp/crd.yaml
#         hack/gen-crd-schema.sh /tmp/crd.yaml

set -euo pipefail

schemas="$(cd "$(dirname "$0")" && pwd)/schemas"

strict='walk(
  if type == "object" then
    (if ."x-kubernetes-int-or-string" == true
       then del(.type, ."x-kubernetes-int-or-string") + {oneOf: [{type: "string"}, {type: "integer"}]}
       else . end)
    | (if has("properties") and (has("additionalProperties") | not)
          and (."x-kubernetes-preserve-unknown-fields" != true)
       then . + {additionalProperties: false}
       else . end)
  else . end)'

for crd in "$@"; do
  group=$(yq '.spec.group' "$crd")
  kind=$(yq '.spec.names.kind | downcase' "$crd")
  for version in $(yq '.spec.versions[].name' "$crd"); do
    out="$schemas/$group/${kind}_${version}.json"
    mkdir -p "$(dirname "$out")"
    yq -o=json ".spec.versions[] | select(.name == \"$version\") | .schema.openAPIV3Schema" "$crd" \
      | jq "$strict" > "$out"
    echo "wrote ${out#"$PWD"/}"
  done
done
