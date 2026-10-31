#!/bin/sh
# Imports the CSK of each zone given as an argument from the knot-keys Secret
# into the empty KASP database, active from the start.
set -eu
for zone in "$@"; do
  keymgr -c "$KNOT_CONFIG" "$zone" import-pem "/keys/$zone.pem" \
    ksk=yes zsk=yes created=+0 publish=+0 ready=+0 active=+0
done
