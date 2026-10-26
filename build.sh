#!/usr/bin/env bash
set -euo pipefail

rm -rf dist _site site.tar.gz
mkdir -p dist _site

cat chunks/part-*.txt | base64 -d > site.tar.gz
tar -xzf site.tar.gz -C _site

cp -a _site/preview/. dist/
mkdir -p dist/public/media/paperly
cp -a _site/public/. dist/public/

# Portfolio-specific PAPERly cover generated for the horizontal presentation.
base64 -d assets/paperly-cover-portfolio.webp.b64 > dist/public/media/paperly/cover-portfolio.webp

find dist -name '*.html' -type f -exec sed -i 's#\.\./public/#public/#g' {} +

python3 - <<'PY'
from pathlib import Path
import re

def replace(path, old, new, required=True):
    p = Path(path)
    text = p.read_text(encoding="utf-8")
    if old not in text:
        if required:
            raise SystemExit(f"Expected text not found in {path}: {old[:100]}")
        return
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

# PAPERly: use the bespoke horizontal key art anywhere PAPERly is represented as a cover.
for html in Path("dist").glob("*.html"):
    text = html.read_text(encoding="utf-8")
    text = text.replace("public/media/paperly/cover.webp", "public/media/paperly/cover-portfolio.webp")
    html.write_text(text, encoding="utf-8")

# Home used a portrait gameplay image in a landscape recruiter tile.
replace(
    "dist/index.html",
    'public/media/paperly/flight-gameplay.webp',
    'public/media/paperly/cover-portfolio.webp'
)
replace(
    "dist/index.html",
    'alt="PAPERly paper plane flying through a low-poly landscape"',
    'alt="PAPERly cover artwork with a paper plane flying over a stylized landscape"',
    required=False
)

# PAPERly gameplay-system cards: portrait screenshots get portrait-aware layouts.
replace(
    "dist/paperly.html",
    '<article class="pp-system wide"><img src="public/media/paperly/flight-gameplay.webp"',
    '<article class="pp-system pp-system-portrait pp-system-feature"><img src="public/media/paperly/flight-gameplay.webp"'
)
replace(
    "dist/paperly.html",
    '<article class="pp-system"><img src="public/media/paperly/launch-state.webp"',
    '<article class="pp-system pp-system-portrait"><img src="public/media/paperly/launch-state.webp"'
)
replace(
    "dist/paperly.html",
    '<article class="pp-system"><img src="public/media/paperly/vortex-gameplay.webp"',
    '<article class="pp-system pp-system-portrait"><img src="public/media/paperly/vortex-gameplay.webp"'
)
replace(
    "dist/paperly.html",
    '<article class="pp-system"><img src="public/media/paperly/upgrades.webp"',
    '<article class="pp-system pp-system-portrait"><img src="public/media/paperly/upgrades.webp"'
)
replace(
    "dist/paperly.html",
    '<article class="pp-system"><img src="public/media/paperly/editor-flight.webp"',
    '<article class="pp-system wide pp-system-landscape"><img src="public/media/paperly/editor-flight.webp"'
)

# PAPERly visual archive: separate true mobile screenshots from implementation/editor material.
p = Path("dist/paperly.html")
text = p.read_text(encoding="utf-8")
new_gallery = r'''
  <section class="c pp-gallery pp-mobile-gallery">
    <div class="pp-galleryhead">
      <div><div class="ey">Mobile / portrait</div><h2>BUILT FOR<br>THE PHONE.</h2></div>
      <p>PAPERly is designed around a vertical mobile viewport. These screens are shown in their native portrait composition instead of being cropped into landscape frames.</p>
    </div>
    <div class="pp-mobilegrid">
      <figure class="pp-mobile-shot"><button class="pp-galleryopen" data-src="public/media/paperly/main-menu.webp" data-alt="PAPERly main menu" data-caption="Main menu with best distance, goal and reward"><img src="public/media/paperly/main-menu.webp" alt="PAPERly main menu"><span>VIEW ↗</span></button><figcaption>Main menu: best distance, next goal and reward loop.</figcaption></figure>
      <figure class="pp-mobile-shot"><button class="pp-galleryopen" data-src="public/media/paperly/upgrades.webp" data-alt="PAPERly upgrades menu" data-caption="Power, Glide, Control and Earnings upgrade screen"><img src="public/media/paperly/upgrades.webp" alt="PAPERly upgrades menu"><span>VIEW ↗</span></button><figcaption>Progression upgrades alter core flight parameters.</figcaption></figure>
      <figure class="pp-mobile-shot"><button class="pp-galleryopen" data-src="public/media/paperly/skins-neon.webp" data-alt="PAPERly neon skin preview" data-caption="Cosmetic skin preview and purchase flow"><img src="public/media/paperly/skins-neon.webp" alt="PAPERly neon skin preview"><span>VIEW ↗</span></button><figcaption>Cosmetic progression and preview flow.</figcaption></figure>
      <figure class="pp-mobile-shot"><button class="pp-galleryopen" data-src="public/media/paperly/new-record.webp" data-alt="PAPERly new record results" data-caption="Flight results with new-record celebration"><img src="public/media/paperly/new-record.webp" alt="PAPERly new record results"><span>VIEW ↗</span></button><figcaption>Run results, earnings and record feedback.</figcaption></figure>
      <figure class="pp-mobile-shot"><button class="pp-galleryopen" data-src="public/media/paperly/settings.webp" data-alt="PAPERly settings screen" data-caption="Settings and reset-progress controls"><img src="public/media/paperly/settings.webp" alt="PAPERly settings screen"><span>VIEW ↗</span></button><figcaption>Settings and reset-progress controls.</figcaption></figure>
    </div>
  </section>

  <section class="c pp-gallery pp-editor-gallery">
    <div class="pp-galleryhead">
      <div><div class="ey">Implementation context</div><h2>GAME VIEW.<br>SCENE VIEW.</h2></div>
      <p>Editor captures and gameplay states keep their own proportions here, so the implementation context stays readable without artificial zoom.</p>
    </div>
    <div class="pp-editorgrid">
      <figure class="pp-editor-shot"><button class="pp-galleryopen" data-src="public/media/paperly/scene-overview.webp" data-alt="PAPERly terrain overview in Unity" data-caption="Full environment and vortex overview inside Unity"><img src="public/media/paperly/scene-overview.webp" alt="PAPERly terrain overview in Unity"><span>VIEW ↗</span></button><figcaption>Full terrain and vortex layout inside Unity.</figcaption></figure>
      <figure class="pp-editor-shot"><button class="pp-galleryopen" data-src="public/media/paperly/vortex-scene.webp" data-alt="PAPERly plane and vortex in Unity Scene view" data-caption="Plane passing near a vortex inside the scene"><img src="public/media/paperly/vortex-scene.webp" alt="PAPERly plane and vortex in Unity Scene view"><span>VIEW ↗</span></button><figcaption>Plane, trails and vortex setup inside Scene view.</figcaption></figure>
      <figure class="pp-editor-shot pp-editor-wide"><button class="pp-galleryopen" data-src="public/media/paperly/out-of-bounds.webp" data-alt="PAPERly out of bounds warning" data-caption="Timed warning when the plane leaves valid playable space"><img src="public/media/paperly/out-of-bounds.webp" alt="PAPERly out of bounds warning"><span>VIEW ↗</span></button><figcaption>Out-of-bounds safety flow and warning state.</figcaption></figure>
    </div>
  </section>
'''
pattern = re.compile(r'\n\s*<section class="c pp-gallery">.*?</section>\s*\n\s*(?=<section class="c pp-story">)', re.S)
text, count = pattern.subn("\n" + new_gallery + "\n", text, count=1)
if count != 1:
    raise SystemExit(f"Expected one PAPERly gallery section, replaced {count}")
p.write_text(text, encoding="utf-8")

# PAPERly-specific visual treatment appended after the legacy rules, so only this case study changes.
css = Path("dist/style.css")
css.write_text(css.read_text(encoding="utf-8") + r'''

/* ===== PAPERly portrait-aware presentation ===== */
.pp-hero-media{
  aspect-ratio:16/9;
  min-height:0!important;
  max-height:none;
}
.pp-hero-media>img{
  object-fit:cover;
  object-position:center;
}
.pp-hero-shade{
  background:linear-gradient(180deg,rgba(5,8,12,.02) 38%,rgba(5,8,12,.78));
}
.pp-hero-label strong{
  font-size:clamp(36px,5.4vw,72px);
}

/* Portrait gameplay evidence is presented beside the explanation instead of cropped behind it. */
.pp-system.pp-system-portrait{
  display:grid;
  grid-template-columns:minmax(190px,40%) minmax(0,1fr);
  min-height:500px;
  background:#0d1219;
}
.pp-system.pp-system-portrait.pp-system-feature{
  grid-column:1/-1;
  grid-template-columns:minmax(260px,300px) minmax(0,1fr);
  min-height:620px;
}
.pp-system.pp-system-portrait>img{
  position:relative;
  inset:auto;
  width:100%;
  height:100%;
  object-fit:cover;
  object-position:center;
  grid-column:1;
  border-right:1px solid var(--l);
  transform:none!important;
}
.pp-system.pp-system-portrait .pp-systemshade{display:none}
.pp-system.pp-system-portrait>div:last-child{
  position:relative;
  left:auto;
  right:auto;
  bottom:auto;
  grid-column:2;
  max-width:none;
  padding:clamp(24px,3vw,38px);
  display:flex;
  flex-direction:column;
  justify-content:flex-end;
  background:
    radial-gradient(circle at 92% 8%,rgba(47,128,255,.12),transparent 30%),
    linear-gradient(145deg,#111822,#0d1219);
}
.pp-system.pp-system-portrait .pp-sysnum{
  right:18px;
  top:18px;
}
.pp-system.pp-system-landscape{
  grid-column:1/-1;
  min-height:520px;
}
.pp-system.pp-system-landscape>img{
  object-fit:cover;
  object-position:center;
}

/* The vortex screenshot is a portrait mobile frame, not a landscape crop. */
.pp-vortexgrid{
  grid-template-columns:minmax(320px,.72fr) 1.28fr;
  align-items:center;
}
.pp-vortexmedia{
  width:min(100%,390px);
  aspect-ratio:560/1254;
  min-height:0;
  justify-self:center;
  border-radius:20px;
  padding:8px;
  background:#080b0f;
  box-shadow:0 28px 80px rgba(0,0,0,.28);
}
.pp-vortexmedia img{
  display:block;
  width:100%;
  height:100%;
  object-fit:cover;
  border-radius:13px;
}

/* Keep the inspector readable at its real vertical proportion. */
.pp-inspector{
  width:min(100%,470px);
  aspect-ratio:633/1251;
  justify-self:center;
  max-height:none!important;
}
.pp-inspector img{
  object-fit:cover;
  object-position:top;
}

/* Dedicated portrait mobile gallery. */
.pp-mobile-gallery{padding-bottom:78px}
.pp-mobilegrid{
  display:grid;
  grid-template-columns:repeat(5,minmax(0,1fr));
  gap:14px;
  align-items:start;
}
.pp-mobile-shot{
  margin:0;
  min-width:0;
}
.pp-mobile-shot .pp-galleryopen{
  aspect-ratio:560/1254;
  padding:7px;
  border:1px solid var(--l);
  border-radius:20px;
  background:#070a0e;
  box-shadow:0 18px 45px rgba(0,0,0,.22);
}
.pp-mobile-shot .pp-galleryopen img{
  display:block;
  width:100%;
  height:100%;
  aspect-ratio:auto;
  object-fit:cover;
  border-radius:13px;
}
.pp-mobile-shot figcaption,
.pp-editor-shot figcaption{
  padding:11px 4px 0;
  color:#8f9aa9;
  font-size:12px;
  line-height:1.45;
}
.pp-mobile-shot .pp-galleryopen>span{
  right:13px;
  bottom:13px;
}
.pp-editor-gallery{padding-top:50px}
.pp-editorgrid{
  display:grid;
  grid-template-columns:repeat(2,minmax(0,1fr));
  gap:16px;
  align-items:start;
}
.pp-editor-shot{
  margin:0;
  min-width:0;
  border:1px solid var(--l);
  background:#0d1117;
}
.pp-editor-shot .pp-galleryopen img{
  display:block;
  width:100%;
  height:auto;
  aspect-ratio:auto;
  object-fit:contain;
}
.pp-editor-shot figcaption{
  padding:12px 14px 14px;
  border-top:1px solid var(--l);
}
.pp-editor-wide{grid-column:1/-1}
.pp-editor-wide .pp-galleryopen{
  max-width:900px;
  margin:0 auto;
}

@media(max-width:1100px){
  .pp-mobilegrid{grid-template-columns:repeat(3,minmax(0,1fr))}
  .pp-system.pp-system-portrait{
    grid-template-columns:minmax(180px,36%) minmax(0,1fr);
  }
}
@media(max-width:900px){
  .pp-system.pp-system-portrait,
  .pp-system.pp-system-portrait.pp-system-feature{
    grid-column:auto;
    grid-template-columns:minmax(210px,310px) minmax(0,1fr);
    min-height:560px;
  }
  .pp-vortexgrid{grid-template-columns:1fr}
  .pp-vortexmedia{margin-bottom:18px}
  .pp-inspector{margin-inline:auto}
}
@media(max-width:700px){
  .pp-hero-media{
    aspect-ratio:16/10;
    min-height:0!important;
  }
  .pp-hero-label{
    left:18px;
    right:18px;
    bottom:18px;
  }
  .pp-hero-label strong{font-size:clamp(30px,9vw,48px)}
  .pp-mobilegrid{grid-template-columns:repeat(2,minmax(0,1fr));gap:12px}
  .pp-system.pp-system-portrait,
  .pp-system.pp-system-portrait.pp-system-feature{
    display:block;
    min-height:0;
  }
  .pp-system.pp-system-portrait>img{
    display:block;
    width:min(100%,360px);
    height:auto;
    aspect-ratio:560/1254;
    margin:0 auto;
    border-right:0;
    border-bottom:1px solid var(--l);
    object-fit:cover;
  }
  .pp-system.pp-system-portrait>div:last-child{
    display:block;
    padding:24px;
  }
  .pp-system.pp-system-portrait .pp-sysnum{
    top:14px;
    right:14px;
  }
  .pp-editorgrid{grid-template-columns:1fr}
  .pp-editor-wide{grid-column:auto}
}
@media(max-width:430px){
  .pp-mobile-shot .pp-galleryopen{padding:5px;border-radius:15px}
  .pp-mobile-shot .pp-galleryopen img{border-radius:10px}
  .pp-mobile-shot figcaption{font-size:11px}
}
''', encoding="utf-8")
PY
