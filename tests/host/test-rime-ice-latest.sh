#!/usr/bin/env bash
set -Eeuo pipefail
python3 -m py_compile scripts/install-rime-ice.py
grep -Fq 'releases/latest/download/full.zip' scripts/install-rime-ice.py
grep -Fq '"--write-out", "%{url_effective}"' scripts/install-rime-ice.py
grep -Fq '"--max-time", "300"' scripts/install-rime-ice.py
grep -Fq 'sha256:' scripts/install-rime-ice.py
grep -Fq 'rime_ice.schema.yaml' scripts/install-rime-ice.py
test -s config/customization/fcitx5/profile
test -s config/customization/fcitx5/org.fcitx.Fcitx5.desktop
test -s config/customization/fcitx5/fcitx5.conf
bash -n scripts/install-fcitx5-customization.sh
grep -Fq 'install-rime-ice.py' scripts/install-fcitx5-customization.sh
grep -Fq 'RIME_ICE_ARCHIVE' scripts/install-fcitx5-customization.sh
grep -Fq 'RIME_ICE_RESOLVED_URL' scripts/build-overlay-root.sh
echo "Rime/Fcitx5 latest-source contract passed"
