#!/usr/bin/env bash
# Render every ArgoCD-managed app the way ArgoCD does, then validate the output
# against the Kubernetes and CRD JSON schemas with kubeconform.
#
# Catches schema-invalid manifests before they reach the cluster. This exists
# because a `names:` / `name:` typo in an AppProject silently broke ArgoCD's
# ServerSideDiff for seven weeks: diffing threw, so the app kept reporting the
# last good comparison and stopped applying anything, including its own upgrade.
#
# Usage:  hack/validate-manifests.sh [dir ...]     (default: all of argocd-managed)
#
# A render failure is a hard failure -- an app whose chart repo has gone away is
# exactly the breakage this is meant to surface. Set SKIP_APPS to tolerate known
# breakage, e.g. SKIP_APPS="sealed-secrets" hack/validate-manifests.sh

set -uo pipefail

KUBE_VERSION="${KUBE_VERSION:-1.33.0}"
SKIP_APPS="${SKIP_APPS:-}"
CATALOG='https://raw.githubusercontent.com/datreeio/CRDs-catalog/main/{{.Group}}/{{.ResourceKind}}_{{.ResourceAPIVersion}}.json'

# kubeconform's built-in `default` location points at the -standalone-strict
# bundles, which have every $ref inlined. CustomResourceDefinition is absent
# from them: its spec pulls in JSONSchemaProps, which references itself, so it
# cannot be flattened. Without this fallback to the plain (ref-using) schemas,
# every CRD in the repo is silently skipped rather than validated.
K8S_SCHEMAS='https://raw.githubusercontent.com/yannh/kubernetes-json-schema/master/{{.NormalizedKubernetesVersion}}/{{.ResourceKind}}{{.KindSuffix}}.json'

kubeconform_args=(
  -strict                                # reject unknown fields on core types too
  -kubernetes-version "$KUBE_VERSION"
  -schema-location default
  -schema-location "$CATALOG"
  -schema-location "$K8S_SCHEMAS"        # so CustomResourceDefinition is checked
  -ignore-missing-schemas                # kinds with no schema anywhere are skipped, not failed
  -summary
)


targets=("$@")
if [ ${#targets[@]} -eq 0 ]; then
  targets=(argocd-managed/*/)
fi

failed=()
skipped=()

for dir in "${targets[@]}"; do
  dir="${dir%/}"
  name="$(basename "$dir")"

  case " $SKIP_APPS " in
    *" $name "*) echo "==> $name (skipped via SKIP_APPS)"; skipped+=("$name"); continue ;;
  esac

  if [ -f "$dir/Chart.yaml" ]; then
    if ! deps=$(helm dependency update "$dir" 2>&1); then
      echo "::error::$name - helm dependency update failed"
      printf '%s\n' "$deps" | tail -3 | sed 's/^/    /'
      failed+=("$name")
      continue
    fi
    # Apps registered with a valuesFile are rendered by ArgoCD once per values
    # variant, not with the chart's default values.yaml. Mirror that, otherwise
    # variant-only fields look missing.
    variants=("$dir"/values-*.yaml)
    if [ -e "${variants[0]}" ]; then
      render() {
        local v
        for v in "${variants[@]}"; do
          helm template "$name" "$dir" --include-crds --values "$v" || return 1
        done
      }
    else
      render() { helm template "$name" "$dir" --include-crds; }
    fi
  elif [ -f "$dir/kustomization.yaml" ]; then
    if command -v kustomize >/dev/null 2>&1; then
      render() { kustomize build "$dir"; }
    else
      render() { kubectl kustomize "$dir"; }
    fi
  else
    continue
  fi

  echo "==> $name"
  if ! output=$(render 2>&1); then
    echo "::error::$name - render failed"
    printf '%s\n' "$output" | tail -5 | sed 's/^/    /'
    failed+=("$name")
    continue
  fi

  if ! printf '%s' "$output" | kubeconform "${kubeconform_args[@]}"; then
    failed+=("$name")
  fi
done

echo
if [ ${#skipped[@]} -gt 0 ]; then
  echo "skipped: ${skipped[*]}"
fi
if [ ${#failed[@]} -gt 0 ]; then
  echo "FAILED: ${failed[*]}"
  exit 1
fi
echo "all manifests valid"
