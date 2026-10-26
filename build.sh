#!/usr/bin/env bash
set -euo pipefail

rm -rf dist _site site.tar.gz
mkdir -p dist _site

cat chunks/part-*.txt | base64 -d > site.tar.gz
tar -xzf site.tar.gz -C _site

cp -a _site/preview/. dist/
mkdir -p dist/public
cp -a _site/public/. dist/public/

find dist -name '*.html' -type f -exec sed -i 's#\.\./public/#public/#g' {} +

python3 - <<'PY'
from pathlib import Path

def replace(path, old, new):
    p = Path(path)
    text = p.read_text(encoding="utf-8")
    if old not in text:
        raise SystemExit(f"Expected text not found in {path}: {old[:80]}")
    p.write_text(text.replace(old, new), encoding="utf-8")

# Work listing: make unfinished case studies explicit without hiding their scope.
replace(
    "dist/work.html",
    '<span class="ey">UNITY / SYSTEMS LAB</span><strong>RPG Systems</strong>',
    '<span class="ey">UNITY / CASE STUDY IN PROGRESS</span><strong>RPG Systems</strong>'
)
replace(
    "dist/work.html",
    '<b>Combat, inventory, dialogue, quests & abilities</b><p>Interconnected character and progression systems.</p>',
    '<b>Combat, inventory, dialogue, quests & abilities</b><p>Project overview available · full case study coming soon.</p>'
)
replace(
    "dist/work.html",
    '<span class="ey">UNITY / SYSTEMS LAB</span><strong>Survival Systems</strong>',
    '<span class="ey">UNITY / CASE STUDY IN PROGRESS</span><strong>Survival Systems</strong>'
)
replace(
    "dist/work.html",
    '<b>Crafting, building, AI & persistence</b><p>Survival mechanics connected through a shared gameplay loop.</p>',
    '<b>Crafting, building, AI & persistence</b><p>Project overview available · full case study coming soon.</p>'
)

# RPG Systems page.
replace(
    "dist/rpg-systems.html",
    '<div class="ey">PERSONAL SYSTEMS LAB / UNITY</div>',
    '<div class="ey">PERSONAL PROJECT / CASE STUDY IN PROGRESS</div>'
)
replace(
    "dist/rpg-systems.html",
    '<div><span>STATUS</span><strong>Personal Lab</strong></div>',
    '<div><span>STATUS</span><strong>Case Study In Progress</strong></div>'
)
replace(
    "dist/rpg-systems.html",
    'The deeper case study will focus on the systems I implemented, modified and integrated, using only material that can be shown publicly.',
    'The full case study is currently being prepared for publication. A deeper breakdown with selected gameplay, implementation details and technical material will be added shortly.'
)

# Survival Systems page.
replace(
    "dist/survival-systems.html",
    '<div class="ey">PERSONAL SYSTEMS LAB / UNITY</div>',
    '<div class="ey">PERSONAL PROJECT / CASE STUDY IN PROGRESS</div>'
)
replace(
    "dist/survival-systems.html",
    '<div><span>STATUS</span><strong>Personal Lab</strong></div>',
    '<div><span>STATUS</span><strong>Case Study In Progress</strong></div>'
)
replace(
    "dist/survival-systems.html",
    'A deeper breakdown will be added once the relevant project material is curated for the portfolio.',
    'The full case study is currently being prepared for publication. A deeper breakdown with selected gameplay, implementation details and technical material will be added shortly.'
)
PY
