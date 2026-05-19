#!/usr/bin/env bash
# Registra un nuevo sufijo (4 hex) y opcionalmente ejecuta bootstrap + deploy.
# Uso: bash seed/add-suffix.sh [suffix]
#   Sin argumento: genera un sufijo aleatorio.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TFVARS="$SCRIPT_DIR/terraform/suffixes.auto.tfvars"
EXAMPLE="$SCRIPT_DIR/terraform/suffixes.auto.tfvars.example"

if [[ ! -f "$TFVARS" ]]; then
  cp "$EXAMPLE" "$TFVARS"
fi

if [[ -n "${1:-}" ]]; then
  NEW_SUFFIX="$1"
  if [[ ! "$NEW_SUFFIX" =~ ^[a-f0-9]{4}$ ]]; then
    echo "ERROR: El sufijo debe ser 4 caracteres hex en minusculas."
    exit 1
  fi
else
  NEW_SUFFIX="$(python -c "import secrets; print(secrets.token_hex(2))")"
fi

python <<PY
import pathlib
import re
import sys

new = sys.argv[1]
path = pathlib.Path(sys.argv[2])
text = path.read_text(encoding="utf-8")
found = re.findall(r'"([a-f0-9]{4})"', text)
if new in found:
    print(f"El sufijo '{new}' ya esta registrado en {path.name}.")
    sys.exit(1)
found.append(new)
lines = ",\n  ".join(f'"{s}"' for s in found)
path.write_text(f"suffixes = [\n  {lines},\n]\n", encoding="utf-8")
print(f"Registrado sufijo: {new}")
print(f"Proyecto GCP: dp-proj-00-03-{new}")
PY
"$NEW_SUFFIX" "$TFVARS"

echo ""
echo "Siguiente:"
echo "  1) bash seed/deploy.sh          # crea proyecto + bucket state (solo el sufijo nuevo)"
echo "  2) bash seed/deploy-block.sh $NEW_SUFFIX   # despliega infra y BD del bloque"
