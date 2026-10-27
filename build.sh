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

# PAPERly launch feedback states.
base64 -d assets/paperly-launch-perfect.png.b64 > dist/public/media/paperly/launch-perfect.png
base64 -d assets/paperly-launch-good.png.b64 > dist/public/media/paperly/launch-good.png
base64 -d assets/paperly-launch-ok.png.b64 > dist/public/media/paperly/launch-ok.png
base64 -d assets/paperly-launch-low-power.png.b64 > dist/public/media/paperly/launch-low-power.png

# Higher-quality gallery assets + dedicated thumbnail set.
cat quality-assets/part-*.txt | base64 -d > gallery-quality-assets.tar.gz
tar -xzf gallery-quality-assets.tar.gz -C dist
rm -f gallery-quality-assets.tar.gz

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

# ===== PAPERly alignment pass =====
# Keep the first four gameplay systems as one clean, aligned portrait row.
replace(
    "dist/paperly.html",
    'class="pp-system pp-system-portrait pp-system-feature"',
    'class="pp-system pp-system-portrait"'
)
replace(
    "dist/paperly.html",
    'class="pp-system wide pp-system-landscape"',
    'class="pp-system pp-system-landscape"'
)

# Four real launch-feedback states, aligned as one comparable set.
replace(
    "dist/paperly.html",
    '<div class="pp-launchvisual"><img src="public/media/paperly/launch-feedback.webp" alt="PAPERly launch timing feedback states"></div>',
    '''<div class="pp-launchvisual pp-feedback-visual">
      <div class="pp-feedback-grid">
        <figure class="pp-feedback-state"><img src="public/media/paperly/launch-perfect.png" alt="PAPERly PERFECT launch feedback"><figcaption>PERFECT</figcaption></figure>
        <figure class="pp-feedback-state"><img src="public/media/paperly/launch-good.png" alt="PAPERly GOOD launch feedback"><figcaption>GOOD</figcaption></figure>
        <figure class="pp-feedback-state"><img src="public/media/paperly/launch-ok.png" alt="PAPERly OK launch feedback"><figcaption>OK</figcaption></figure>
        <figure class="pp-feedback-state"><img src="public/media/paperly/launch-low-power.png" alt="PAPERly LOW POWER launch feedback"><figcaption>LOW POWER</figcaption></figure>
      </div>
    </div>'''
)

# The three implementation-context images should read as one aligned row.
replace(
    "dist/paperly.html",
    'class="pp-editor-shot pp-editor-wide"',
    'class="pp-editor-shot"'
)

css = Path("dist/style.css")
css.write_text(css.read_text(encoding="utf-8") + r'''

/* ===== PAPERly alignment pass ===== */

/* Systems: four equal mobile cards, then one deliberate full-width technical card. */
.pp-systemgrid{
  grid-template-columns:repeat(4,minmax(0,1fr))!important;
  gap:14px!important;
  align-items:stretch;
}
.pp-system.pp-system-portrait{
  display:flex!important;
  flex-direction:column;
  min-height:0!important;
  grid-column:auto!important;
  background:#0d1219;
}
.pp-system.pp-system-portrait>img{
  position:relative!important;
  inset:auto!important;
  display:block;
  width:100%!important;
  height:auto!important;
  aspect-ratio:560/1254;
  object-fit:cover!important;
  object-position:center!important;
  border-right:0!important;
  border-bottom:1px solid var(--l);
  transform:none!important;
}
.pp-system.pp-system-portrait .pp-systemshade{display:none!important}
.pp-system.pp-system-portrait>div:last-child{
  position:relative!important;
  left:auto!important;
  right:auto!important;
  bottom:auto!important;
  display:block!important;
  flex:1;
  padding:22px 20px 24px!important;
  background:
    radial-gradient(circle at 92% 8%,rgba(47,128,255,.1),transparent 30%),
    linear-gradient(145deg,#111822,#0d1219);
}
.pp-system.pp-system-portrait h3{
  font-size:clamp(25px,2.25vw,36px)!important;
  line-height:.92;
}
.pp-system.pp-system-portrait p{
  font-size:13px;
  line-height:1.55;
}
.pp-system.pp-system-portrait .pp-sysnum{
  top:14px!important;
  right:14px!important;
}

.pp-system.pp-system-landscape{
  grid-column:1/-1!important;
  min-height:0!important;
  display:grid!important;
  grid-template-columns:minmax(0,1.15fr) minmax(300px,.85fr);
  align-items:stretch;
}
.pp-system.pp-system-landscape>img{
  position:relative!important;
  inset:auto!important;
  display:block;
  width:100%!important;
  height:100%!important;
  min-height:400px;
  object-fit:cover!important;
  object-position:center!important;
  transform:none!important;
}
.pp-system.pp-system-landscape .pp-systemshade{display:none!important}
.pp-system.pp-system-landscape>div:last-child{
  position:relative!important;
  left:auto!important;
  right:auto!important;
  bottom:auto!important;
  max-width:none!important;
  padding:38px!important;
  display:flex;
  flex-direction:column;
  justify-content:flex-end;
  border-left:1px solid var(--l);
  background:
    radial-gradient(circle at 92% 8%,rgba(47,128,255,.12),transparent 30%),
    linear-gradient(145deg,#111822,#0d1219);
}
.pp-system.pp-system-landscape h3{
  font-size:clamp(34px,4vw,56px)!important;
}

/* Timing: PERFECT / GOOD / OK / LOW POWER as four equal states. */
.pp-feedback-visual{
  padding:22px;
  display:grid;
  place-items:center;
  background:
    radial-gradient(circle at 50% 35%,rgba(47,128,255,.08),transparent 55%),
    #090d12;
}
.pp-feedback-grid{
  width:100%;
  display:grid;
  grid-template-columns:repeat(4,minmax(0,1fr));
  gap:12px;
  align-items:start;
}
.pp-feedback-state{
  margin:0;
  min-width:0;
}
.pp-feedback-state img{
  display:block;
  width:100%;
  height:auto!important;
  aspect-ratio:110/355;
  object-fit:cover!important;
  object-position:center;
  border:1px solid var(--l);
  background:#0b1016;
}
.pp-feedback-state figcaption{
  padding:9px 2px 0;
  text-align:center;
  color:#8f9aa9;
  font:10px ui-monospace;
  letter-spacing:.08em;
}

/* Game View / Scene View: three equal cards on one row. */
.pp-editorgrid{
  grid-template-columns:repeat(3,minmax(0,1fr))!important;
  gap:14px!important;
  align-items:stretch!important;
}
.pp-editor-shot{
  display:flex;
  flex-direction:column;
  min-width:0;
  height:100%;
}
.pp-editor-shot .pp-galleryopen{
  aspect-ratio:1/1;
  display:grid;
  place-items:center;
  padding:8px;
  background:#070a0e;
}
.pp-editor-shot .pp-galleryopen img{
  width:100%!important;
  height:100%!important;
  aspect-ratio:auto!important;
  object-fit:contain!important;
}
.pp-editor-shot figcaption{
  flex:1;
}

@media(max-width:1100px){
  .pp-systemgrid{grid-template-columns:repeat(2,minmax(0,1fr))!important}
  .pp-system.pp-system-landscape{grid-column:1/-1!important}
}
@media(max-width:900px){
  .pp-feedback-grid{grid-template-columns:repeat(2,minmax(0,1fr))}
  .pp-editorgrid{grid-template-columns:repeat(3,minmax(0,1fr))!important}
}
@media(max-width:700px){
  .pp-systemgrid{grid-template-columns:1fr!important}
  .pp-system.pp-system-landscape{
    grid-column:auto!important;
    grid-template-columns:1fr;
  }
  .pp-system.pp-system-landscape>img{
    height:auto!important;
    min-height:0;
    aspect-ratio:1.2/1;
    object-fit:cover!important;
  }
  .pp-system.pp-system-landscape>div:last-child{
    border-left:0;
    border-top:1px solid var(--l);
    padding:24px!important;
  }
  .pp-editorgrid{grid-template-columns:1fr!important}
}
''', encoding="utf-8")


# ===== Home hero media pass =====
# The hero uses four landscape covers; preserve each full composition instead of cropping it.
replace(
    "dist/index.html",
    '<a class="showcase-tile showcase-main" href="paperly.html">',
    '<a class="showcase-tile showcase-main showcase-paperly" href="paperly.html">'
)
replace(
    "dist/index.html",
    '<a class="showcase-tile" href="nba-bounce.html">',
    '<a class="showcase-tile showcase-nba" href="nba-bounce.html">'
)
replace(
    "dist/index.html",
    '<a class="showcase-tile" href="bandit-trail.html">',
    '<a class="showcase-tile showcase-bandit" href="bandit-trail.html">'
)
replace(
    "dist/index.html",
    '<a class="showcase-tile showcase-wide" href="kids-table.html">',
    '<a class="showcase-tile showcase-wide showcase-kids" href="kids-table.html">'
)

css = Path("dist/style.css")
css.write_text(css.read_text(encoding="utf-8") + r'''

/* ===== Home hero media pass ===== */
.recruiter-showcase{
  min-height:min(62vh,580px)!important;
  grid-template-columns:repeat(2,minmax(0,1fr))!important;
  grid-template-rows:repeat(2,minmax(0,1fr))!important;
  gap:10px!important;
  padding:10px!important;
}
.showcase-main,
.showcase-wide{
  grid-row:auto!important;
  grid-column:auto!important;
}
.showcase-tile{
  position:relative;
  isolation:isolate;
  display:grid!important;
  grid-template-rows:minmax(0,1fr) auto;
  min-height:0;
  overflow:hidden;
  background:#080c11!important;
}
.showcase-tile::before{
  content:"";
  position:absolute;
  z-index:0;
  inset:-16px;
  background-size:cover;
  background-position:center;
  filter:blur(20px) brightness(.38) saturate(.82);
  transform:scale(1.12);
  opacity:.95;
}
.showcase-paperly::before{background-image:url("public/media/paperly/cover-portfolio.webp")}
.showcase-nba::before{background-image:url("public/media/credits/nba-bounce/cover.webp")}
.showcase-bandit::before{background-image:url("public/media/bandit-trail/cover.webp")}
.showcase-kids::before{background-image:url("public/media/kids-table/cover.webp")}
.showcase-tile::after{
  content:"";
  position:absolute;
  z-index:0;
  inset:0;
  background:linear-gradient(180deg,rgba(6,9,13,.04),rgba(6,9,13,.18));
  pointer-events:none;
}
.showcase-tile img{
  position:relative;
  z-index:1;
  display:block;
  width:100%!important;
  height:100%!important;
  min-width:0;
  min-height:0;
  padding:8px;
  object-fit:contain!important;
  object-position:center!important;
  transform:none!important;
  filter:none!important;
}
.showcase-tile:hover img,
.showcase-tile:focus-visible img{
  transform:scale(1.012)!important;
  filter:brightness(1.04)!important;
}
.showcase-tile .tile-shade{
  display:none!important;
}
.showcase-tile .tile-copy{
  position:relative!important;
  z-index:2;
  left:auto!important;
  right:auto!important;
  bottom:auto!important;
  grid-row:2;
  padding:10px 12px 12px;
  border-top:1px solid rgba(255,255,255,.09);
  background:rgba(7,10,15,.91);
  backdrop-filter:blur(8px);
}
.showcase-tile .tile-copy small{
  font-size:8px;
}
.showcase-tile .tile-copy strong{
  font-size:clamp(16px,1.45vw,22px);
}
.showcase-label{
  top:20px!important;
  right:20px!important;
  left:auto!important;
  pointer-events:none;
}

@media(max-width:1100px){
  .recruiter-showcase{
    min-height:540px!important;
  }
}
@media(max-width:720px){
  .recruiter-showcase{
    min-height:460px!important;
    gap:8px!important;
    padding:8px!important;
  }
  .showcase-tile img{
    padding:5px;
  }
  .showcase-tile .tile-copy{
    padding:8px 9px 9px;
  }
  .showcase-tile .tile-copy small{
    font-size:7px;
  }
  .showcase-tile .tile-copy strong{
    font-size:15px;
  }
  .showcase-label{
    top:14px!important;
    right:14px!important;
    font-size:7px!important;
  }
}
@media(max-width:430px){
  .recruiter-showcase{
    min-height:430px!important;
  }
}
''', encoding="utf-8")



# DayZ workflow language clarification.
replace(
    "dist/dayz.html",
    "The assignment was carried out through Lionbridge Warsaw as a subcontracted QA task. Testing, issue reporting and the working language for the project were all in English.",
    "The assignment was carried out through Lionbridge Warsaw as a subcontracted QA task. Testing and issue reporting were handled in English, while day-to-day communication within the Warsaw team also included Polish."
)

# ===== V18 bilingual ES layer =====
# English routes stay untouched; Spanish lives under /es/ and shares all media/styles.
import shutil

bilingual_pages = [
    "index.html","work.html","credits.html","about.html","contact.html",
    "paperly.html","bandit-trail.html","kids-table.html","rpg-systems.html",
    "survival-systems.html","nba-bounce.html","barbie-horse-trails.html",
    "dayz.html","chicken-run-eggstraction.html",
    "the-cat-in-the-hat-rainy-day-mayhem.html",
]

ES_EXACT = {
    # Global navigation / UI
    "Skip to content":"Saltar al contenido",
    "Work":"Proyectos",
    "Credits":"Créditos",
    "About":"Sobre mí",
    "Contact":"Contacto",
    "Professional credits":"Créditos profesionales",
    "Selected work":"Proyectos destacados",
    "View selected work ↗":"Ver proyectos destacados ↗",
    "Get in touch ↗":"Contactar ↗",
    "CONTACT ↗":"CONTACTO ↗",
    "EMAIL ↗":"EMAIL ↗",
    "LINKEDIN ↗":"LINKEDIN ↗",
    "About me ↗":"Sobre mí ↗",
    "Explore credits ↗":"Ver créditos ↗",
    "Explore case study ↗":"Ver caso de estudio ↗",
    "Explore personal projects ↗":"Ver proyectos personales ↗",
    "Open case study ↗":"Ver caso de estudio ↗",
    "Open credit ↗":"Ver crédito ↗",
    "View professional credits ↗":"Ver créditos profesionales ↗",
    "View official game ↗":"Ver juego oficial ↗",
    "VIEW OFFICIAL GAME ↗":"VER JUEGO OFICIAL ↗",
    "ALL CREDITS":"TODOS LOS CRÉDITOS",
    "ALL CREDITS ↗":"TODOS LOS CRÉDITOS ↗",
    "ALL PROJECTS":"TODOS LOS PROYECTOS",
    "← WORK":"← PROYECTOS",
    "← PROFESSIONAL CREDITS":"← CRÉDITOS PROFESIONALES",
    "← PREVIOUS CREDIT":"← CRÉDITO ANTERIOR",
    "NEXT CREDIT →":"SIGUIENTE CRÉDITO →",
    "← PREVIOUS PROJECT":"← PROYECTO ANTERIOR",
    "NEXT PROJECT →":"SIGUIENTE PROYECTO →",
    "ROLE":"ROL",
    "ENGINE":"MOTOR",
    "PERIOD":"PERIODO",
    "FOCUS":"ENFOQUE",
    "STATUS":"ESTADO",
    "PLATFORM":"PLATAFORMA",
    "INPUT":"CONTROL",
    "PROJECT TYPE":"TIPO DE PROYECTO",
    "COMPANY":"EMPRESA",
    "YEAR":"AÑO",
    "INVOLVEMENT":"PARTICIPACIÓN",
    "DEVELOPER":"DESARROLLADOR",
    "PUBLISHER":"EDITOR",
    "Contribution":"Contribución",
    "Scope":"Alcance",
    "Workflow":"Flujo de trabajo",
    "Official media":"Material oficial",
    "Official trailers":"Tráilers oficiales",
    "Professional credit":"Crédito profesional",
    "Featured":"Destacados",
    "Personal projects":"Proyectos personales",
    "Languages":"Idiomas",
    "Next":"Siguiente",
    "MAIN":"PRINCIPAL",
    "TESTED":"PROBADO",
    "All":"Todos",
    "Showing all 3 personal projects.":"Mostrando los 3 proyectos personales.",
    "Case Study In Progress":"Caso de estudio en preparación",
    "PROJECT COLLECTION":"COLECCIÓN DE PROYECTOS",
    "ONGOING COLLECTION":"COLECCIÓN EN DESARROLLO",
    "PUBLIC BUILD":"BUILD PÚBLICA",
    "FULL PRODUCTION":"PRODUCCIÓN COMPLETA",
    "TARGETED QA SUPPORT":"SOPORTE QA PUNTUAL",
    "EARLY BETA QA":"QA EN BETA TEMPRANA",
    "ADDITIONAL CONTENT QA":"QA DE CONTENIDO ADICIONAL",
    "PRIMARY FOCUS":"ENFOQUE PRINCIPAL",
    "IMPLEMENTATION":"IMPLEMENTACIÓN",
    "METHOD":"MÉTODO",
    "CORE DISCIPLINE":"DISCIPLINA PRINCIPAL",
    "ADDITIONAL VALUE":"VALOR ADICIONAL",
    "COMMUNICATION":"COMUNICACIÓN",
    "CREDITS":"CRÉDITOS",
    "COMMERCIAL CREDITS":"CRÉDITOS COMERCIALES",
    "WORKING LANGUAGE":"IDIOMA DE TRABAJO",
    "PRIMARY STACK":"STACK PRINCIPAL",
    "REAL PROJECT MATERIAL / SELECTED WORK":"MATERIAL REAL DE PROYECTO / TRABAJO DESTACADO",

    # Home
    "DESIGN THINKING.":"DISEÑO.",
    "TECHNICAL EXECUTION.":"EJECUCIÓN TÉCNICA.",
    "Recruiter shortcut":"Acceso rápido",
    "START WITH THE SIGNAL.":"EMPIEZA POR LO ESENCIAL.",
    "END-TO-END DEVELOPMENT":"DESARROLLO END-TO-END",
    "COMMERCIAL PRODUCTION":"PRODUCCIÓN COMERCIAL",
    "PROJECTS WITH":"PROYECTOS CON",
    "REAL OWNERSHIP.":"RESPONSABILIDAD REAL.",
    "Profile":"Perfil",
    "DESIGN ×":"DISEÑO ×",
    "ENGINEERING":"INGENIERÍA",
    "OPEN TO GAME":"ABIERTO A OPORTUNIDADES",
    "DEVELOPMENT ROLES.":"EN DESARROLLO DE VIDEOJUEGOS.",
    "5 titles":"5 títulos",
    "English C1":"Inglés C1",
    "01 / Featured project":"01 / Proyecto destacado",
    "02 / Featured project":"02 / Proyecto destacado",
    "03 / Project collection":"03 / Colección de proyectos",
    "Systems, genres & experiments":"Sistemas, géneros y experimentos",
    "Educational games & interactive systems":"Juegos educativos y sistemas interactivos",
    "Original infinite runner / shooter":"Infinite runner / shooter original",
    "Explore personal projects ↗":"Ver proyectos personales ↗",

    # Work
    "DESIGN.":"DISEÑA.",
    "BUILD. ITERATE.":"CONSTRUYE. ITERA.",
    "SELECTED CASE STUDIES.":"CASOS DE ESTUDIO DESTACADOS.",
    "SYSTEMS, GENRES":"SISTEMAS, GÉNEROS",
    "& EXPERIMENTS.":"Y EXPERIMENTOS.",
    "Flight, game feel & progression":"Vuelo, game feel y progresión",
    "Combat, inventory, dialogue, quests & abilities":"Combate, inventario, diálogo, misiones y habilidades",
    "Crafting, building, AI & persistence":"Crafteo, construcción, IA y persistencia",
    "Project overview available · full case study coming soon.":"Resumen disponible · caso de estudio completo próximamente.",
    "Gameplay Systems":"Sistemas de gameplay",

    # Credits listing
    "COMMERCIAL":"CRÉDITOS",
    "CREDITS.":"PROFESIONALES.",
    "FULL PRODUCTION":"PRODUCCIÓN COMPLETA",
    "TARGETED QA SUPPORT":"SOPORTE QA PUNTUAL",
    "EARLY BETA QA":"QA EN BETA TEMPRANA",

    # About / contact
    "About / Pedro Pinczura":"Sobre mí / Pedro Pinczura",
    "What I do":"Qué hago",
    "THREE SIDES OF":"TRES DISCIPLINAS.",
    "THE SAME PROBLEM.":"UN MISMO PERFIL.",
    "Gameplay & Systems Design":"Diseño de gameplay y sistemas",
    "Technical Implementation":"Implementación técnica",
    "QA-informed Development":"Desarrollo guiado por QA",
    "Design → implementation":"Diseño → implementación",
    "BRIDGING BOTH SIDES.":"UNIENDO DISEÑO Y TÉCNICA.",
    "Experience snapshot":"Experiencia",
    "FROM PROTOTYPES":"DE PROTOTIPOS",
    "TO SHIPPED GAMES.":"A JUEGOS PUBLICADOS.",
    "Core stack":"Stack principal",
    "TOOLS I WORK WITH":"HERRAMIENTAS DE TRABAJO",
    "WORKING ACROSS TEAMS":"TRABAJANDO ENTRE EQUIPOS",
    "Native":"Nativo",
    "C1 / Advanced":"C1 / Avanzado",
    "Elementary":"Básico",
    "LET'S BUILD SOMETHING PLAYABLE.":"HAGAMOS ALGO JUGABLE.",
    "Contact / Pedro Pinczura":"Contacto / Pedro Pinczura",
    "LET'S BUILD":"HAGAMOS",
    "SOMETHING PLAYABLE.":"ALGO JUGABLE.",
    "Download résumé":"Descargar CV",

    # PAPERly
    "Design goal":"Objetivo de diseño",
    "ARCADE FLIGHT.":"VUELO ARCADE.",
    "NOT A SCRIPTED RIDE.":"NO UN RECORRIDO PREFIJADO.",
    "Core gameplay loop":"Bucle principal",
    "LAUNCH. FLY.":"LANZA. VUELA.",
    "COME BACK STRONGER.":"VUELVE MÁS LEJOS.",
    "Launch":"Lanzamiento",
    "Fly":"Vuelo",
    "Distance":"Distancia",
    "Earn":"Recompensa",
    "Upgrade & Retry":"Mejora y repite",
    "Gameplay systems":"Sistemas de gameplay",
    "SYSTEMS THAT":"SISTEMAS QUE",
    "SHAPE THE FLIGHT.":"DEFINEN EL VUELO.",
    "CUSTOM FLIGHT MODEL":"MODELO DE VUELO PERSONALIZADO",
    "MOBILE STEERING":"CONTROL MÓVIL",
    "VORTEX INTERACTION":"INTERACCIÓN CON VÓRTICES",
    "PROGRESSION":"PROGRESIÓN",
    "GAME FEEL LAYER":"CAPA DE GAME FEEL",
    "Technical breakdown":"Desglose técnico",
    "SMALL SYSTEMS.":"SISTEMAS PEQUEÑOS.",
    "CLEAR RESPONSIBILITIES.":"RESPONSABILIDADES CLARAS.",
    "Designer-facing tuning":"AJUSTE PARA DISEÑO",
    "TUNABLE":"AJUSTABLE",
    "BY DESIGN.":"POR DISEÑO.",
    "Launch interaction":"Interacción de lanzamiento",
    "TIMING BECOMES":"EL TIMING SE CONVIERTE EN",
    "FEEL.":"SENSACIÓN.",
    "Mechanic + feedback":"Mecánica + feedback",
    "THE VORTEX":"EL VÓRTICE",
    "CHANGES THE RUN.":"CAMBIA LA PARTIDA.",
    "Iteration":"Iteración",
    "FIX THE FEEL,":"ARREGLA LA SENSACIÓN,",
    "NOT JUST THE BUG.":"NO SOLO EL BUG.",
    "WORLD SAFETY":"SEGURIDAD DEL MUNDO",
    "Built for the phone":"Diseñado para móvil",
    "BUILT FOR":"DISEÑADO PARA",
    "THE PHONE.":"EL MÓVIL.",
    "GAME VIEW.":"GAME VIEW.",
    "SCENE VIEW.":"SCENE VIEW.",
    "Current state":"Estado actual",

    # Bandit Trail
    "Original gameplay, public release and player-driven iteration.":"Gameplay original, lanzamiento público e iteración guiada por jugadores.",
    "Gameplay systems":"Sistemas de gameplay",
    "Visual archive":"Archivo visual",
    "THE RUN,":"LA PARTIDA,",
    "UP CLOSE.":"DE CERCA.",

    # KIDS'TABLE
    "PROFESSIONAL / UNITY":"PROFESIONAL / UNITY",
    "DESIGN → CODE → DELIVERY":"DISEÑO → CÓDIGO → ENTREGA",
    "PRODUCT IN USE.":"PRODUCTO EN USO.",

    # RPG / Survival
    "CONNECTED, NOT ISOLATED.":"CONECTADOS, NO AISLADOS.",
    "SURVIVAL AS A SYSTEM NETWORK.":"SUPERVIVENCIA COMO RED DE SISTEMAS.",

    # Professional credit common
    "WHAT I WORKED ON":"EN QUÉ TRABAJÉ",
    "SIX PLATFORMS.":"SEIS PLATAFORMAS.",
    "ONE QUALITY BAR.":"UN MISMO NIVEL DE CALIDAD.",
    "CROSS-PLATFORM.":"MULTIPLATAFORMA.",
    "RULES & CONTENT":"REGLAS Y CONTENIDO",
    "VALIDATION.":"VALIDACIÓN.",
    "CROSS-PLATFORM,":"MULTIPLATAFORMA,",
    "IN ENGLISH.":"EN INGLÉS.",
    "Gameplay & design feedback":"Feedback de gameplay y diseño",
    "BEYOND":"MÁS ALLÁ DE",
    "BUG FINDING.":"ENCONTRAR BUGS.",
    "Shot feel":"Sensación de tiro",
    "Gameplay exploits":"Exploits de gameplay",
    "Alley-oop flow":"Flujo del alley-oop",
    "GAMEPLAY":"GAMEPLAY",
    "GALLERY.":"GALERÍA.",
    "WATCH THE":"VER EL",
    "GAME IN MOTION.":"JUEGO EN MOVIMIENTO.",
    "Launch Trailer":"Tráiler de lanzamiento",
    "Announcement Trailer":"Tráiler de anuncio",
    "Gameplay Trailer":"Tráiler de gameplay",
    "Gameplay Reveal":"Presentación de gameplay",
    "Open-world UX":"UX de mundo abierto",
    "NAVIGATION &":"NAVEGACIÓN Y",
    "UI clarity":"Claridad de UI",
    "Mission flow":"Flujo de misiones",
    "World navigation":"Navegación del mundo",
    "Primary test target":"Plataforma principal de pruebas",
    "TEST ENVIRONMENT.":"ENTORNO DE PRUEBAS.",
    "Combat content QA":"QA de contenido de combate",
    "WEAPONS, EQUIPMENT":"ARMAS, EQUIPAMIENTO",
    "& ITEMS.":"Y OBJETOS.",
    "State coverage":"Cobertura de estados",
    "ANIMATIONS THROUGH":"ANIMACIONES DURANTE",
    "MOVEMENT.":"EL MOVIMIENTO.",
    "· IN ENGLISH.":"· EN INGLÉS.",
    "Test targets":"Plataformas probadas",
    "TARGETED COVERAGE":"COBERTURA PUNTUAL",
    "ACROSS THREE BUILDS.":"EN TRES BUILDS.",
    "CHARACTERS, MISSIONS":"PERSONAJES, MISIONES",
    "& PROGRESSION.":"Y PROGRESIÓN.",
    "Contribution scope":"Alcance de la contribución",
    "FOCUSED SUPPORT.":"SOPORTE CONCRETO.",
    "CLEAR OWNERSHIP.":"ALCANCE CLARO.",
    "Test target":"Plataforma probada",
    "EARLY-BETA VALIDATION":"VALIDACIÓN EN BETA TEMPRANA",
    "ON STEAM.":"EN STEAM.",
    "Early beta QA":"QA en beta temprana",
    "TESTING A":"PROBANDO UN",
    "MOVING TARGET.":"OBJETIVO EN MOVIMIENTO.",
    "TARGETED NEW-CONTENT":"SOPORTE PUNTUAL A",
    "SUPPORT.":"CONTENIDO NUEVO.",
    "MINIGAMES":"MINIJUEGOS",
    "& GAMEPLAY.":"Y GAMEPLAY.",
    "Mini Trailer":"Mini tráiler",

    # V18 polish: remaining visible UI / labels
    "View selected work":"Ver proyectos destacados",
    "COMMERCIAL QA + DESIGN FEEDBACK":"QA COMERCIAL + FEEDBACK DE DISEÑO",
    "UE4 / ORIGINAL PROJECT":"UE4 / PROYECTO ORIGINAL",
    "TECHNICAL DESIGN / LEAD PROGRAMMING":"TECHNICAL DESIGN / LEAD PROGRAMMING",
    "Build · Test · Iterate":"Construir · Probar · Iterar",
    "UE4 / PUBLIC BUILD":"UE4 / BUILD PÚBLICA",
    "UNITY / PROFESSIONAL":"UNITY / PROFESIONAL",
    "UNITY / CASE STUDY IN PROGRESS":"UNITY / CASO DE ESTUDIO EN PREPARACIÓN",
    "Custom flight model, touch steering, camera, vortices and upgrades.":"Modelo de vuelo personalizado, control táctil, cámara, vórtices y mejoras.",
    "English production teams":"Equipos de producción en inglés",
    "Functional QA · full production cycle · design feedback":"Functional QA · ciclo completo de producción · feedback de diseño",
    "Functional QA · full production cycle · design / UX feedback":"Functional QA · ciclo completo de producción · feedback de diseño / UX",
    "Functional QA · weapons, equipment & item validation":"Functional QA · validación de armas, equipamiento y objetos",
    "Functional QA · targeted production support":"Functional QA · soporte puntual de producción",
    "Functional QA · early beta · new content validation":"Functional QA · beta temprana · validación de contenido nuevo",
    "PROFESSIONAL CREDITS":"CRÉDITOS PROFESIONALES",
    "01 / DESIGN":"01 / DISEÑO",
    "02 / IMPLEMENTATION":"02 / IMPLEMENTACIÓN",
    "03 / ITERATION":"03 / ITERACIÓN",
    "Balancing":"Balance",
    "Prototyping":"Prototipado",
    "Regression":"Regresión",
    "Bug Analysis":"Análisis de bugs",
    "Design Feedback":"Feedback de diseño",
    "Documentation":"Documentación",
    "MADRID, SPAIN":"MADRID, ESPAÑA",
    "DESIGN × CODE × ITERATION":"DISEÑO × CÓDIGO × ITERACIÓN",
    "LAUNCH.":"LANZA.",
    "FLY. PUSH FURTHER.":"VUELA. LLEGA MÁS LEJOS.",
    "Original personal project":"Proyecto personal original",
    "Mobile / portrait":"Móvil / vertical",
    "Touch + keyboard testing":"Táctil + teclado para testing",
    "Flight feel / tuning / progression":"Feel de vuelo / tuning / progresión",
    "Camera":"Cámara",
    "Progression":"Progresión",
    "Weak / OK / Good / Perfect feedback":"Feedback Weak / OK / Good / Perfect",
    "Vertical boost":"Boost vertical",
    "Fall compensation":"Compensación de caída",
    "Capped gravity penalty":"Penalización de gravedad limitada",
    "Audio + particles + camera shake":"Audio + partículas + camera shake",
    "Scale punch":"Punch de escala",
    "Jitter → LateUpdate follow":"Jitter → seguimiento en LateUpdate",
    "Pitch direction & readable roll":"Pitch direccional y roll legible",
    "Boost without infinite ascent":"Boost sin ascenso infinito",
    "Leaving the terrain is a game state":"Salir del terreno es un estado de juego",
    "Current State":"Estado actual",
    "Scene Overview":"Vista general de escena",
    "Vortex Scene":"Escena de vórtice",
    "Out of Bounds":"Fuera de límites",

    # Gallery captions / alt text
    "NBA BOUNCE characters and mascots on court":"Personajes y mascotas de NBA BOUNCE en pista",
    "NBA BOUNCE mascot dunking":"Mascota de NBA BOUNCE realizando un mate",
    "NBA BOUNCE multiplayer gameplay on the Utah court":"Gameplay multijugador de NBA BOUNCE en la pista de Utah",
    "NBA BOUNCE gameplay on the Milwaukee court":"Gameplay de NBA BOUNCE en la pista de Milwaukee",
    "NBA BOUNCE gameplay on the Detroit court":"Gameplay de NBA BOUNCE en la pista de Detroit",
    "NBA BOUNCE Dallas Mavericks mascot gameplay shot":"Gameplay con la mascota de Dallas Mavericks en NBA BOUNCE",
    "NBA BOUNCE gameplay on the Los Angeles Lakers court":"Gameplay de NBA BOUNCE en la pista de Los Angeles Lakers",
    "NBA BOUNCE mascot lineup":"Alineación de mascotas de NBA BOUNCE",
    "NBA BOUNCE winner screen":"Pantalla de victoria de NBA BOUNCE",

    "Barbie Horse Trails horse care and grooming":"Cuidado y cepillado del caballo en Barbie Horse Trails",
    "Barbie Horse Trails group riding through Canterbury Trails Park":"Grupo cabalgando por Canterbury Trails Park",
    "Barbie Horse Trails riding near a waterfall and bridge":"Cabalgando junto a una cascada y un puente",
    "Barbie Horse Trails horse customization screen":"Pantalla de personalización del caballo",
    "Barbie Horse Trails exploration beside a lake":"Exploración junto a un lago",
    "Barbie Horse Trails horseback exploration":"Exploración a caballo",
    "Barbie Horse Trails character customization footwear":"Personalización de calzado del personaje",
    "Barbie Horse Trails character outfit customization":"Personalización de ropa del personaje",
    "Barbie Horse Trails pottery reconstruction activity":"Actividad de reconstrucción de cerámica",

    "Chicken Run Eggstraction outdoor stealth area":"Zona exterior de sigilo en Chicken Run: Eggstraction",
    "Chicken Run Eggstraction interior stealth encounter":"Encuentro de sigilo en interior",
    "Chicken Run Eggstraction treetop environment and traversal area":"Entorno en altura y zona de traversal",
    "Chicken Run Eggstraction garden stealth gameplay":"Gameplay de sigilo en el jardín",
    "Chicken Run Eggstraction water-side escape environment":"Entorno de escape junto al agua",

    "The Cat in the Hat Rainy Day Mayhem basketball minigame":"Minijuego de baloncesto de The Cat in the Hat",
    "The Cat in the Hat Rainy Day Mayhem basket carry minigame":"Minijuego de transporte de cesta",
    "The Cat in the Hat Rainy Day Mayhem maze minigame":"Minijuego de laberinto",
    "The Cat in the Hat Rainy Day Mayhem kitchen minigame":"Minijuego de cocina",
    "The Cat in the Hat Rainy Day Mayhem dialogue scene":"Escena de diálogo",
    "The Cat in the Hat Rainy Day Mayhem sorting minigame":"Minijuego de clasificación",
    "The Cat in the Hat Rainy Day Mayhem painting minigame":"Minijuego de pintura",
    "The Cat in the Hat Rainy Day Mayhem four player split screen minigame":"Minijuego a pantalla dividida para cuatro jugadores",

    "Licensed QA":"QA DE CONTENIDO LICENCIADO",
    "RULES & CONTENT":"VALIDACIÓN DE",
    "VALIDATION.":"REGLAS Y CONTENIDO.",
    "COMMERCIAL CREDITS":"CRÉDITOS PROFESIONALES",
    "Bandit Trail character standing in a western town":"Personaje de Bandit Trail en un pueblo del oeste",
    "Bandit Trail gameplay showing the player character, enemies and HUD":"Gameplay de Bandit Trail con jugador, enemigos y HUD",
    "Bandit Trail character running through an open western environment":"Personaje corriendo por un entorno abierto del oeste",
    "Enemy outlaw firing a weapon in Bandit Trail":"Enemigo forajido disparando en Bandit Trail",
    "Rifle-wielding enemy in Bandit Trail":"Enemigo armado con rifle en Bandit Trail",
    "Female playable character holding a firearm in Bandit Trail":"Personaje jugable femenino con arma de fuego",
    "Player shooting an explosive barrel in Bandit Trail":"Jugador disparando a un barril explosivo",
    "Player running through a dry biome with large bones":"Jugador atravesando un bioma seco con grandes huesos",
    "Player running through a greener biome in Bandit Trail":"Jugador atravesando un bioma más verde",
    "Outlaw aiming a rifle in Bandit Trail":"Forajido apuntando con un rifle en Bandit Trail",

    "Two children playing together on the yellow KIDS'TABLE":"Dos niños jugando juntos en la KIDS'TABLE amarilla",
    "Two children interacting with a KIDS'TABLE educational activity":"Dos niños interactuando con una actividad educativa de KIDS'TABLE",
    "Children interacting with a game on KIDS'TABLE":"Niños interactuando con un juego en KIDS'TABLE",
    "Adult and child playing together on a red KIDS'TABLE":"Adulto y niño jugando juntos en una KIDS'TABLE roja",
    "Yellow KIDS'TABLE hardware":"Hardware amarillo de KIDS'TABLE",
    "Purple KIDS'TABLE hardware":"Hardware morado de KIDS'TABLE",
    "Selection of educational applications available on KIDS'TABLE":"Selección de aplicaciones educativas disponibles en KIDS'TABLE",
    "KIDS'TABLE branding and educational application previews":"Branding de KIDS'TABLE y previews de aplicaciones educativas",
}

ES_PHRASES = [
    # Home
    ("Technical Designer with hands-on experience across game design, Unity / C#, Unreal / Blueprints and Functional QA. I build gameplay systems, prototype quickly, iterate from player feedback and support commercial production.",
     "Technical Designer con experiencia práctica en diseño de juego, Unity / C#, Unreal / Blueprints y Functional QA. Desarrollo sistemas de gameplay, prototipo con rapidez, itero a partir del feedback de jugadores y trabajo dentro de producción comercial."),
    ("Three fast entry points into the work that best represents my range across Technical Design, end-to-end development and commercial QA.",
     "Tres accesos rápidos al trabajo que mejor representa mi perfil entre Technical Design, desarrollo end-to-end y QA comercial."),
    ("Custom flight model, touch steering, camera feel, environmental boosts and progression — built to be tuned and iterated in Unity.",
     "Modelo de vuelo personalizado, control táctil, cámara, boosts ambientales y progresión; todo preparado para ajustar e iterar en Unity."),
    ("Design, C# implementation, integration and coordination across a large catalogue of educational mini-games for shipped hardware.",
     "Diseño, implementación en C#, integración y coordinación en un amplio catálogo de minijuegos educativos para hardware comercializado."),
    ("Full-cycle, multi-platform Functional QA with gameplay feedback, licensed-content validation and direct studio communication in English.",
     "Functional QA multiplataforma durante todo el ciclo de producción, con feedback de gameplay, validación de contenido licenciado y comunicación directa con el estudio en inglés."),
    ("Free movement, shooting, enemy encounters and changing environments, developed from concept to public release and iterated with player feedback.",
     "Movimiento libre, disparos, enemigos y entornos variables, desarrollado desde concepto hasta lanzamiento público e iterado con feedback de jugadores."),
    ("End-to-end technical design, gameplay implementation and coordination across a large catalog of educational mini-games.",
     "Technical Design end-to-end, implementación de gameplay y coordinación en un amplio catálogo de minijuegos educativos."),
    ("Explore the rest of my personal work across different genres, gameplay systems and technical experiments.",
     "Explora el resto de mis proyectos personales entre distintos géneros, sistemas de gameplay y experimentos técnicos."),
    ("NBA BOUNCE, Barbie Horse Trails, DayZ, Chicken Run and The Cat in the Hat — with contribution scope made explicit on every page.",
     "Créditos en NBA BOUNCE, Barbie Horse Trails, DayZ, Chicken Run y The Cat in the Hat, con el alcance de mi trabajo claramente detallado."),
    ("Experience, technical focus, tools and the multidisciplinary path behind my Technical Design profile.",
     "Experiencia, enfoque técnico y herramientas que definen mi perfil como Technical Designer."),
    ("Technical Design is my main focus, but I’m also open to Game Design, Gameplay Programming, Unity / Unreal development, Functional QA and entry-level Production opportunities.",
     "Technical Design es mi enfoque principal, pero también estoy abierto a oportunidades en Game Design, Gameplay Programming, desarrollo con Unity / Unreal, Functional QA y posiciones junior de Production."),

    # Work
    ("Case studies that show how I approach gameplay, implementation, iteration and production — followed by a growing systems lab across different genres.",
     "Casos de estudio que muestran cómo trabajo gameplay, implementación, iteración y producción, junto a una colección creciente de sistemas en distintos géneros."),
    ("Filter the collection by the kind of work you want to inspect. Detailed write-ups are added only when there is enough public material to support them properly.",
     "Filtra la colección por el tipo de trabajo que quieras revisar. Los análisis detallados se publican solo cuando existe suficiente material público para documentarlos correctamente."),
    ("Design, development, playtesting and iteration.",
     "Diseño, desarrollo, playtesting e iteración."),
    ("Technical Design, implementation and coordination.",
     "Technical Design, implementación y coordinación."),

    # Credits listing
    ("Professional game credits with deliberately clear contribution scopes. Open a title to see exactly what I tested, validated or contributed before following the official game links.",
     "Créditos profesionales con un alcance de contribución deliberadamente claro. Abre cada título para ver exactamente qué probé, validé o aporté antes de acceder a los enlaces oficiales."),

    # About
    ("I’m a Technical Designer with a multidisciplinary background across game design, gameplay programming and functional QA.",
     "Soy Technical Designer con un perfil multidisciplinar entre diseño de juego, gameplay programming y functional QA."),
    ("Technical Design is my primary focus, but I’m open to opportunities across Game Design, Gameplay Programming, Unity / Unreal development, QA and entry-level Production. I’m most comfortable where disciplines overlap: building mechanics, exposing meaningful parameters for iteration, identifying gameplay problems and translating design intent into working systems.",
     "Technical Design es mi enfoque principal, aunque también estoy abierto a oportunidades en Game Design, Gameplay Programming, desarrollo con Unity / Unreal, QA y Production junior. Me siento especialmente cómodo donde las disciplinas se solapan: construyendo mecánicas, exponiendo parámetros útiles para iterar, detectando problemas de gameplay y traduciendo intención de diseño a sistemas funcionales."),
    ("I care about how a system feels in the player’s hands, but also about how clearly it can be tuned, tested, documented and maintained by a production team.",
     "Me importa cómo se siente un sistema en manos del jugador, pero también que pueda ajustarse, probarse, documentarse y mantenerse con claridad dentro de un equipo de producción."),
    ("Mechanics, progression, game feel, player feedback, UX and balancing decisions grounded in iteration and playtesting.",
     "Mecánicas, progresión, game feel, feedback del jugador, UX y decisiones de balance apoyadas en iteración y playtesting."),
    ("Hands-on implementation of gameplay systems and prototypes in Unity / C#, alongside Unreal Engine / Blueprints experience and a strong interest in gameplay programming across both engines.",
     "Implementación directa de sistemas de gameplay y prototipos en Unity / C#, junto a experiencia con Unreal Engine / Blueprints y un fuerte interés por gameplay programming en ambos motores."),
    ("Functional testing, bug analysis and design feedback used as part of the development loop rather than as a final validation step.",
     "Testing funcional, análisis de bugs y feedback de diseño integrados en el ciclo de desarrollo, no únicamente como validación final."),
    ("I started from a game-design background and progressively moved toward technical implementation. That lets me approach gameplay problems from both perspectives: what the player should experience and what the system needs to do to create that experience reliably.",
     "Partí de una base de Game Design y fui desplazándome progresivamente hacia la implementación técnica. Eso me permite abordar problemas de gameplay desde ambos lados: qué debería experimentar el jugador y qué necesita hacer el sistema para producir esa experiencia de forma consistente."),
    ("I enjoy building systems that can be iterated quickly, exposing useful parameters to designers and using observation, testing and feedback to improve the final result.",
     "Disfruto construyendo sistemas que puedan iterarse rápido, exponiendo parámetros útiles para diseño y usando observación, testing y feedback para mejorar el resultado final."),
    ("Multi-platform functional QA and gameplay / UX feedback across commercial releases including NBA BOUNCE and Barbie Horse Trails.",
     "Functional QA multiplataforma y feedback de gameplay / UX en lanzamientos comerciales como NBA BOUNCE y Barbie Horse Trails."),
    ("Design and implementation of educational mobile minigames, technical documentation and hands-on programming across projects from concept to final delivery.",
     "Diseño e implementación de minijuegos educativos para móvil, documentación técnica y programación directa desde concepto hasta entrega final."),
    ("Functional QA in English on DayZ content, with a focus on weapons, equipment, items and animation / interaction validation.",
     "Functional QA en inglés sobre contenido de DayZ, con foco en armas, equipamiento, objetos y validación de animaciones / interacciones."),
    ("Co-development of an original UE4 endless runner from concept through public demos, iteration and player feedback.",
     "Co-desarrollo de un endless runner original en UE4 desde concepto hasta demos públicas, iteración y feedback de jugadores."),
    ("Open to opportunities across game development, with a particular focus on Technical Design, Game Design and Gameplay Programming — plus Unity / Unreal development, QA and Production.",
     "Abierto a oportunidades en desarrollo de videojuegos, con especial foco en Technical Design, Game Design y Gameplay Programming, además de desarrollo con Unity / Unreal, QA y Production."),

    # Contact
    ("I’m open to opportunities across game development, with a particular focus on Technical Design, Game Design and Gameplay Programming.",
     "Estoy abierto a oportunidades en desarrollo de videojuegos, especialmente en Technical Design, Game Design y Gameplay Programming."),
    ("My background spans design, programming and QA, so I’m comfortable contributing across disciplines. I’m also open to starting in Production and specialising further as I grow within a team. For opportunities or questions about my work, email or LinkedIn are the fastest ways to reach me.",
     "Mi experiencia combina diseño, programación y QA, por lo que me siento cómodo colaborando entre disciplinas. También estoy abierto a comenzar en Production y especializarme a medida que crezca dentro de un equipo. Para oportunidades o preguntas sobre mi trabajo, email o LinkedIn son las vías más rápidas para contactarme."),

    # PAPERly
    ("A mobile arcade flight prototype built around launch timing, custom flight tuning, touch steering, environmental boosts and progression.",
     "Un prototipo móvil de vuelo arcade construido alrededor del timing de lanzamiento, ajuste personalizado del vuelo, control táctil, boosts ambientales y progresión."),
    ("One repeatable loop connects launch timing, flight feel, environmental boosts, rewards and upgrades.",
     "Un bucle repetible conecta timing de lanzamiento, sensación de vuelo, boosts ambientales, recompensas y mejoras."),
    ("The goal was to make the plane immediately readable on mobile while preserving enough momentum, descent, steering inertia and environmental interaction for each run to feel skill-based. The controller is intentionally tunable so the feel can be iterated without rebuilding the system.",
     "El objetivo era que el avión fuese inmediatamente legible en móvil manteniendo suficiente inercia, descenso, resistencia al giro e interacción ambiental para que cada partida dependiese de la habilidad. El controlador está diseñado para ser ajustable y poder iterar el feel sin reconstruir el sistema."),
    ("Movement, touch input, environmental boosts and progression all modify the same underlying flight model instead of behaving like disconnected features.",
     "Movimiento, input táctil, boosts ambientales y progresión modifican el mismo modelo de vuelo base en lugar de comportarse como sistemas desconectados."),
    ("Forward motion, vertical velocity, custom gravity, progressive speed and terminal descent are combined into a deliberately arcade-oriented controller.",
     "Movimiento hacia delante, velocidad vertical, gravedad personalizada, velocidad progresiva y descenso terminal se combinan en un controlador deliberadamente arcade."),
    ("Drag input passes through a dead zone, normalized distance and smoothing before affecting yaw acceleration and visual roll.",
     "El drag pasa por una zona muerta, distancia normalizada y suavizado antes de afectar a la aceleración de yaw y al roll visual."),
    ("Boost, fall compensation and an accumulating gravity penalty turn each vortex into a useful but non-free extension of the run.",
     "El boost, la compensación de caída y una penalización acumulativa de gravedad convierten cada vórtice en una extensión útil de la partida, pero no gratuita."),
    ("Power, Glide and Control upgrades directly modify launch, gravity and steering parameters.",
     "Las mejoras de Power, Glide y Control modifican directamente parámetros de lanzamiento, gravedad y dirección."),
    ("Pitch, roll, wobble, trails, camera tilt and dynamic FOV communicate the simulation without making the physics itself unstable.",
     "Pitch, roll, wobble, trails, inclinación de cámara y FOV dinámico comunican la simulación sin volver inestable la física."),
    ("The case study shows selected excerpts rather than whole scripts. The point is to expose the design logic behind the flight, not turn the portfolio into a source-code dump.",
     "El caso de estudio muestra fragmentos seleccionados en lugar de scripts completos. El objetivo es enseñar la lógica de diseño detrás del vuelo, no convertir el portfolio en un volcado de código."),
    ("The flight model is exposed through serialized parameters, making iteration visible and fast. The current scene tuning also demonstrates why this matters: several values have moved beyond their original script defaults as the feel evolved.",
     "El modelo de vuelo expone sus parámetros serializados para que la iteración sea visible y rápida. El tuning actual de la escena también muestra por qué importa: varios valores han cambiado respecto a los defaults originales a medida que evolucionó el feel."),
    ("The power bar does more than choose a number. It freezes the player's timing, classifies the outcome, changes visual treatment and delivers a short punch before handing the normalized value to the flight controller.",
     "La barra de potencia hace más que elegir un número. Congela el timing del jugador, clasifica el resultado, cambia el tratamiento visual y aplica un pequeño punch antes de enviar el valor normalizado al controlador de vuelo."),
    ("The zone validates the current game state and cooldown, applies the gameplay change through the plane controller, then layers feedback on top of the mechanic.",
     "La zona valida el estado actual del juego y el cooldown, aplica el cambio de gameplay a través del controlador del avión y después añade las capas de feedback sobre la mecánica."),
    ("The follow pass was moved into LateUpdate and smoothed independently from the plane simulation so camera motion no longer fights the Rigidbody update.",
     "El seguimiento se movió a LateUpdate y se suavizó de forma independiente a la simulación del avión para que la cámara dejase de competir con la actualización del Rigidbody."),
    ("Visual pitch and roll were tuned separately from positional movement, allowing the plane to communicate climb, descent and steering without destabilizing the simulation.",
     "El pitch y roll visuales se ajustaron por separado del movimiento posicional, permitiendo comunicar ascenso, descenso y dirección sin desestabilizar la simulación."),
    ("Vortices evolved from a simple upward push into fall compensation plus a run-level gravity penalty, keeping them desirable while preserving descent pressure.",
     "Los vórtices evolucionaron de un simple empuje vertical a compensación de caída más una penalización de gravedad por partida, manteniéndolos atractivos sin eliminar la presión del descenso."),
    ("Bounds and terrain checks now trigger a timed warning before forcing the crash flow, avoiding silent failures when the plane leaves valid playable space.",
     "Los checks de límites y terreno activan ahora una advertencia temporizada antes de forzar el crash, evitando fallos silenciosos cuando el avión sale del espacio jugable."),
    ("PAPERly is designed around a vertical mobile viewport. These screens are shown in their native portrait composition instead of being cropped into landscape frames.",
     "PAPERly está diseñado alrededor de un viewport móvil vertical. Estas pantallas se muestran en su composición portrait nativa en lugar de recortarlas dentro de marcos horizontales."),
    ("Editor captures and gameplay states keep their own proportions here, so the implementation context stays readable without artificial zoom.",
     "Las capturas del editor y los estados de gameplay mantienen aquí sus proporciones originales para que el contexto de implementación siga siendo legible sin zoom artificial."),
    ("PAPERly currently connects launch timing, touch steering, custom flight, vortices, distance tracking, earnings, upgrades, skins, records, settings and map-safety handling into one repeatable mobile loop. Gameplay video and additional iteration footage can be added later without changing the structure of this case study.",
     "PAPERly conecta actualmente timing de lanzamiento, control táctil, vuelo personalizado, vórtices, distancia, ganancias, mejoras, skins, récords, ajustes y seguridad del mapa en un único bucle móvil repetible. Se podrán añadir vídeos de gameplay y más material de iteración sin cambiar la estructura del caso de estudio."),

    # Bandit Trail
    ("Original infinite runner / shooter combining free movement, combat, enemy encounters and changing environments.",
     "Infinite runner / shooter original que combina movimiento libre, combate, encuentros con enemigos y entornos variables."),
    ("Instead of restricting the player to fixed lanes or simple obstacle avoidance, we wanted each run to give the player more agency. Bandit Trail combines free movement, shooting, enemies and changing environments to create a more active take on the infinite-runner formula.",
     "En lugar de limitar al jugador a carriles fijos o simple esquiva de obstáculos, queríamos que cada partida ofreciese más agencia. Bandit Trail combina movimiento libre, disparos, enemigos y entornos cambiantes para crear una versión más activa de la fórmula infinite runner."),
    ("Each system supports the same goal: keeping movement, decision-making and combat active inside a continuous run.",
     "Cada sistema persigue el mismo objetivo: mantener movimiento, toma de decisiones y combate activos dentro de una partida continua."),
    ("The runner format is opened up beyond fixed lanes, allowing the player to move freely through the playable space while reacting to obstacles and threats.",
     "El formato runner se abre más allá de los carriles fijos, permitiendo al jugador moverse libremente por el espacio jugable mientras reacciona a obstáculos y amenazas."),
    ("Ranged combat is integrated directly into the running loop, so navigation and combat happen at the same time.",
     "El combate a distancia se integra directamente en el bucle de carrera, haciendo que navegación y combate ocurran al mismo tiempo."),
    ("Armed enemies introduce active threats beyond environmental obstacles.",
     "Los enemigos armados introducen amenazas activas más allá de los obstáculos del entorno."),
    ("Runs take place across procedurally generated maps with changing obstacle layouts and environmental variation.",
     "Las partidas se desarrollan en mapas generados proceduralmente con distribuciones variables de obstáculos y cambios de entorno."),
    ("Dollars and Wanted Level feed into unlockable weapons and character skins.",
     "Los dólares y el Wanted Level alimentan el desbloqueo de armas y skins de personaje."),
    ("Bandit Trail began as the final project for a university course, but development continued after the original submission. Jorge León Elías and I worked collaboratively across design, implementation, integration, testing and iteration instead of dividing the project into isolated disciplines.",
     "Bandit Trail comenzó como proyecto final de una asignatura universitaria, pero el desarrollo continuó tras la entrega. Jorge León Elías y yo trabajamos de forma colaborativa entre diseño, implementación, integración, testing e iteración, en lugar de dividir el proyecto en disciplinas aisladas."),
    ("We released free playable builds and shared the project through public development channels so external players could test it and suggest gameplay improvements. That made the project an exercise in publishing and user-driven iteration rather than a closed academic prototype.",
     "Publicamos builds jugables gratuitas y compartimos el proyecto en canales públicos de desarrollo para que jugadores externos pudiesen probarlo y sugerir mejoras de gameplay. Eso convirtió el proyecto en un ejercicio de publicación e iteración guiada por usuarios, no en un prototipo académico cerrado."),
    ("The Windows build remains publicly downloadable on itch.io. The project page also preserves public player comments and the gameplay trailer, giving the case study a verifiable record of the release and feedback process.",
     "La build de Windows sigue disponible públicamente en itch.io. La página conserva comentarios de jugadores y el tráiler de gameplay, dejando un registro verificable del lanzamiento y del proceso de feedback."),
    ("Bandit Trail was created from zero together with Jorge León Elías. We shared the same responsibilities and worked across the whole project, supporting each other in design, programming, art and animation integration, testing and iteration.",
     "Bandit Trail fue creado desde cero junto a Jorge León Elías. Compartimos responsabilidades y trabajamos sobre todo el proyecto, apoyándonos en diseño, programación, integración de arte y animación, testing e iteración."),
    ("Both of us contributed to the design and implementation of the gameplay and to taking the project from an academic starting point to a publicly playable release.",
     "Ambos contribuimos al diseño e implementación del gameplay y a llevar el proyecto desde un punto de partida académico hasta un lanzamiento públicamente jugable."),

    # KIDS'TABLE
    ("Professional Technical Design and Lead Programming across educational mini-games and interactive systems.",
     "Technical Design profesional y Lead Programming en minijuegos educativos y sistemas interactivos."),
    ("KIDS'TABLE is an interactive children's table combining a large touchscreen with educational applications and video content. Public product material describes more than 150 educational applications aimed at children from 3 to 9 years old.",
     "KIDS'TABLE es una mesa interactiva infantil que combina una gran pantalla táctil con aplicaciones educativas y contenido de vídeo. El material público del producto describe más de 150 aplicaciones educativas dirigidas a niños de 3 a 9 años."),
    ("Working in a small-company environment meant covering gameplay and interaction design, hands-on C# programming, technical decisions, integration, iteration and coordination with external programmers. I designed a large portion of the mini-games and programmed approximately 90% of the mini-games on the table, taking many of them from initial concept through implementation and final delivery.",
     "Trabajar en una empresa pequeña implicaba cubrir diseño de gameplay e interacción, programación directa en C#, decisiones técnicas, integración, iteración y coordinación con programadores externos. Diseñé una gran parte de los minijuegos y programé aproximadamente el 90% de los minijuegos de la mesa, llevando muchos desde concepto inicial hasta implementación y entrega final."),
    ("The project repeatedly required moving between design intent and implementation: defining how an educational interaction should behave, translating it into a playable system, testing it on the target hardware and iterating until it was ready to ship.",
     "El proyecto exigía moverse continuamente entre intención de diseño e implementación: definir cómo debía comportarse una interacción educativa, traducirla a un sistema jugable, probarla en el hardware objetivo e iterar hasta dejarla lista para publicar."),
    ("A deeper breakdown of selected mini-games, systems and implementation decisions will be added once the remaining development material has been gathered.",
     "Se añadirá un análisis más profundo de minijuegos, sistemas y decisiones de implementación seleccionadas cuando esté reunido el material de desarrollo restante."),
    ("Public-facing product imagery already gives the project a strong visual layer. Selected gameplay breakdowns can be added later without changing this structure.",
     "El material público del producto ya aporta una capa visual sólida. Más adelante podrán añadirse análisis de gameplay concretos sin cambiar esta estructura."),

    # RPG / Survival
    ("A personal Unity project connecting combat, inventory, dialogue, quests, shops and abilities into a cohesive RPG prototype.",
     "Proyecto personal en Unity que conecta combate, inventario, diálogo, misiones, tiendas y habilidades dentro de un prototipo RPG cohesionado."),
    ("Combat, inventory, dialogue, quests, shops and abilities are treated as parts of the same player progression loop. The full case study is currently being prepared for publication. A deeper breakdown with selected gameplay, implementation details and technical material will be added shortly.",
     "Combate, inventario, diálogo, misiones, tiendas y habilidades se tratan como partes del mismo bucle de progresión del jugador. El caso de estudio completo está en preparación y próximamente se añadirá un desglose más profundo con gameplay, detalles de implementación y material técnico."),
    ("A survival prototype connecting player needs, inventory, resource gathering, crafting, base building, NPC combat and save/load systems.",
     "Prototipo de supervivencia que conecta necesidades del jugador, inventario, recolección de recursos, crafting, construcción de base, combate con NPC y sistemas de guardado/carga."),
    ("Player survival mechanics, inventory, resource gathering, crafting, construction, NPC AI and combat, persistence and environment prototyping form the core of the project. The full case study is currently being prepared for publication. A deeper breakdown with selected gameplay, implementation details and technical material will be added shortly.",
     "Mecánicas de supervivencia, inventario, recolección, crafting, construcción, IA y combate de NPC, persistencia y prototipado de entorno forman el núcleo del proyecto. El caso de estudio completo está en preparación y próximamente se añadirá un desglose más profundo con gameplay, implementación y material técnico."),

    # NBA
    ("Full-cycle functional QA across console and PC builds, with cross-platform regression, bug reporting and verification, licensed-content validation, and gameplay/design feedback shared directly with the development studio in English.",
     "Functional QA durante todo el ciclo de producción en builds de consola y PC, con regresión multiplataforma, reporte y verificación de bugs, validación de contenido licenciado y feedback de gameplay/diseño compartido directamente con el estudio en inglés."),
    ("I worked on NBA BOUNCE throughout the full production cycle, testing builds across console and PC, reproducing and classifying issues, validating fixes and feeding gameplay observations back to the development studio.",
     "Trabajé en NBA BOUNCE durante todo el ciclo de producción, probando builds de consola y PC, reproduciendo y clasificando incidencias, validando fixes y trasladando observaciones de gameplay al estudio."),
    ("This page is intentionally scoped to my contribution. It does not imply ownership of the wider game or work completed by the development team outside my QA and design-feedback role.",
     "Esta página limita deliberadamente el alcance a mi contribución. No implica autoría sobre el juego completo ni sobre el trabajo realizado por el equipo de desarrollo fuera de mi función de QA y feedback de diseño."),
    ("My main day-to-day focus was Nintendo Switch, PlayStation 5 and Steam, while still validating behaviour across the wider project matrix.",
     "Mi foco diario principal fue Nintendo Switch, PlayStation 5 y Steam, aunque también validé comportamiento en el resto de la matriz de plataformas."),
    ("Testing also involved checking behaviour against official NBA rules and reviewing licensed presentation details. I reported gameplay cases that conflicted with expected basketball rules while also validating visual elements such as team identities, colours, courts and mascots.",
     "El testing también incluía comprobar comportamientos frente a las reglas oficiales de la NBA y revisar detalles de presentación licenciados. Reporté casos de gameplay que entraban en conflicto con reglas esperadas del baloncesto y validé elementos visuales como identidades de equipos, colores, pistas y mascotas."),
    ("Bug reports, classifications, verification work and communication with the external development studio were handled in English throughout production.",
     "Los reportes de bugs, clasificaciones, verificaciones y la comunicación con el estudio externo se realizaron en inglés durante toda la producción."),
    ("Alongside functional QA, I raised gameplay-focused observations where edge cases, animation flow or shot behaviour affected the intended arcade feel.",
     "Además del Functional QA, trasladé observaciones de gameplay cuando casos límite, transiciones de animación o comportamientos de tiro afectaban a la experiencia arcade prevista."),
    ("Reviewed awkward shooting situations such as attempts from behind the basket or from extreme angles, and provided feedback when the result felt inconsistent with the intended arcade basketball experience.",
     "Revisé situaciones de tiro poco naturales, como intentos desde detrás de la canasta o ángulos extremos, y aporté feedback cuando el resultado no encajaba con la experiencia arcade prevista."),
    ("Identified edge cases where specific combinations of sprint speed, shot-meter timing and very long-distance attempts could produce overly reliable rebounds and baskets.",
     "Identifiqué casos límite donde determinadas combinaciones de velocidad de sprint, timing del medidor y tiros desde muy lejos podían producir rebotes y canastas excesivamente fiables."),
    ("Suggested making the aerial catch-to-dunk sequence feel smoother and more expressive, including additional aerial movement or freestyle before the finish.",
     "Propuse hacer más fluida y expresiva la secuencia de recepción aérea y mate, incluyendo movimiento o freestyle adicional antes de finalizar."),
    ("Public promotional screenshots give visual context to the commercial title I tested. Click any image to expand it.",
     "Las capturas promocionales públicas aportan contexto visual al título comercial que probé. Pulsa cualquier imagen para ampliarla."),

    # Barbie
    ("Full-cycle functional QA across console and PC builds, with cross-platform regression, bug reporting and verification, plus gameplay and UX feedback focused on interface clarity, world navigation and mission progression.",
     "Functional QA durante todo el ciclo de producción en consola y PC, con regresión multiplataforma, reporte y verificación de bugs, además de feedback de gameplay y UX centrado en claridad de interfaz, navegación y progresión de misiones."),
    ("I worked across the full production cycle, testing console and PC builds, reproducing and classifying issues, validating fixes and sharing gameplay and UX observations directly with the US-based development studio in English.",
     "Trabajé durante todo el ciclo de producción probando builds de consola y PC, reproduciendo y clasificando incidencias, validando fixes y compartiendo observaciones de gameplay y UX directamente con el estudio estadounidense en inglés."),
    ("My day-to-day focus was Nintendo Switch, PlayStation 5 and Steam, while I also validated behaviour across the wider project test matrix.",
     "Mi foco diario fue Nintendo Switch, PlayStation 5 y Steam, aunque también validé comportamiento en el resto de la matriz de pruebas."),
    ("Because the game is built around exploring Canterbury Trails Park, part of my feedback focused on how players move between objectives. I reviewed mission routes, repeated travel and UI friction, then raised suggestions intended to keep exploration readable without unnecessary backtracking.",
     "Como el juego gira alrededor de explorar Canterbury Trails Park, parte de mi feedback se centró en cómo se desplaza el jugador entre objetivos. Revisé rutas de misión, recorridos repetidos y fricción de UI, proponiendo cambios para mantener una exploración clara sin backtracking innecesario."),
    ("Testing, bug reports, classifications, verification work and direct communication with the US-based development studio were handled in English throughout production.",
     "Testing, reportes de bugs, clasificaciones, verificaciones y comunicación directa con el estudio estadounidense se realizaron en inglés durante toda la producción."),
    ("Alongside functional QA, I provided UX and gameplay feedback aimed at reducing friction in a large explorable environment and keeping mission progression clear and comfortable for the player.",
     "Además del functional QA, aporté feedback de UX y gameplay orientado a reducir fricción en un entorno amplio y mantener clara y cómoda la progresión de misiones."),
    ("Flagged interface elements that felt overly aggressive or visually intrusive when they obstructed the player or competed too strongly with the gameplay view.",
     "Señalé elementos de interfaz demasiado agresivos o intrusivos cuando tapaban al jugador o competían en exceso con la vista de gameplay."),
    ("Reviewed mission routes and progression where objectives could create too much backtracking, and suggested changes that made the route through the world feel more efficient.",
     "Revisé rutas y progresión de misiones donde los objetivos generaban demasiado backtracking y propuse cambios para hacer más eficiente el recorrido por el mundo."),
    ("Proposed shortcuts, teleports and fast-travel opportunities in key areas to reduce repetitive traversal and make navigation through the open world smoother.",
     "Propuse atajos, teletransportes y puntos de viaje rápido en zonas clave para reducir desplazamientos repetitivos y hacer más fluida la navegación por el mundo abierto."),

    # DayZ
    ("PC / Steam functional QA focused on weapons, equipment and items around additional content planned for the game, with repeated balance and behaviour validation in a dedicated combat test environment.",
     "Functional QA en PC / Steam centrado en armas, equipamiento y objetos relacionados con contenido adicional planificado para el juego, con validaciones repetidas de balance y comportamiento en un entorno de combate dedicado."),
    ("My contribution was a PC / Steam QA assignment focused on weapon, equipment and item content. The work combined functional validation with repeated comparison of weapon behaviour and balance, plus animation and traversal coverage for equipped and stowed states.",
     "Mi contribución fue una asignación de QA en PC / Steam centrada en armas, equipamiento y objetos. El trabajo combinó validación funcional con comparaciones repetidas de comportamiento y balance de armas, además de cobertura de animaciones y traversal en estados equipados y guardados."),
    ("This page is intentionally scoped to my contribution. It does not imply ownership of DayZ or work completed by Bohemia Interactive outside my Lionbridge QA assignment.",
     "Esta página limita deliberadamente el alcance a mi contribución. No implica autoría sobre DayZ ni sobre el trabajo realizado por Bohemia Interactive fuera de mi asignación de QA con Lionbridge."),
    ("My contribution was focused exclusively on the Steam build, using a dedicated scenario designed to exercise weapons, targets, enemies, equipment and interaction states repeatedly and consistently.",
     "Mi contribución se centró exclusivamente en la build de Steam, usando un escenario dedicado para probar de forma repetible y consistente armas, objetivos, enemigos, equipamiento y estados de interacción."),
    ("The test pass covered both the new content being prepared and the wider weapon set around it. I repeatedly compared weapon behaviour and balance in a controlled scenario with different enemies and target types, while also validating equipment and item behaviour around the combat loop.",
     "El pase de testing cubría tanto el nuevo contenido en preparación como el conjunto de armas relacionado. Comparé repetidamente comportamiento y balance de armas en un escenario controlado con distintos enemigos y tipos de objetivo, validando también equipamiento y objetos alrededor del bucle de combate."),
    ("Validation went beyond weapon stats. I checked how weapons and equipment behaved visually when equipped or stowed and while the character changed state: climbing ladders, moving up and down slopes, jumping and traversing the environment. This exposed animation, attachment, clipping and state-transition issues that could appear only in specific movement contexts.",
     "La validación iba más allá de las estadísticas de armas. Comprobé cómo se comportaban visualmente armas y equipamiento al estar equipados o guardados mientras el personaje cambiaba de estado: escaleras, pendientes, saltos y traversal. Esto permitía detectar problemas de animación, attachment, clipping y transiciones que solo aparecían en contextos concretos."),
    ("The assignment was carried out through Lionbridge Warsaw as a subcontracted QA task. Testing and issue reporting were handled in English, while day-to-day communication within the Warsaw team also included Polish.",
     "La asignación se realizó a través de Lionbridge Warsaw como tarea de QA subcontratada. El testing y los reportes se gestionaban en inglés, mientras que la comunicación diaria dentro del equipo de Varsovia también incluía polaco."),
    ("Public DayZ imagery gives visual context to the systems and content types covered by the QA assignment. Click any image to expand it.",
     "Las imágenes públicas de DayZ aportan contexto visual a los sistemas y tipos de contenido cubiertos por la asignación de QA. Pulsa cualquier imagen para ampliarla."),

    # Chicken Run
    ("Targeted functional QA support on Steam, Nintendo Switch and PlayStation 5, focused on characters, missions, unlocks, items and progression when the wider production test effort needed additional coverage.",
     "Soporte puntual de functional QA en Steam, Nintendo Switch y PlayStation 5, centrado en personajes, misiones, desbloqueos, objetos y progresión cuando la producción necesitaba cobertura adicional."),
    ("My contribution was pure functional QA, joining the wider test effort when extra coverage was needed. I repeatedly validated expected game behaviour across characters, missions, unlock conditions, progression and items, reproducing issues through practical trial-and-error testing and verifying correct results.",
     "Mi contribución fue functional QA puro, incorporándome al esfuerzo de testing cuando se necesitaba cobertura adicional. Validé repetidamente el comportamiento esperado de personajes, misiones, condiciones de desbloqueo, progresión y objetos, reproduciendo incidencias mediante pruebas prácticas y verificando los resultados correctos."),
    ("This page is intentionally scoped to my targeted QA contribution. It does not imply full-production involvement or ownership of work completed by Aardman Animations, Outright Games or other teams on the project.",
     "Esta página limita deliberadamente el alcance a mi contribución puntual de QA. No implica participación durante toda la producción ni autoría sobre el trabajo realizado por Aardman Animations, Outright Games u otros equipos."),
    ("My support focused on the Steam, Nintendo Switch and PlayStation 5 builds. The assignment was deliberately scoped: I joined the QA effort when additional functional coverage was needed rather than working across the full production cycle.",
     "Mi soporte se centró en las builds de Steam, Nintendo Switch y PlayStation 5. El alcance era deliberadamente concreto: me incorporé al equipo de QA cuando se necesitaba cobertura funcional adicional, no durante todo el ciclo de producción."),
    ("The work was pure functional QA: repeatedly testing expected behaviour, reproducing issues and checking that characters, missions, unlock conditions and items behaved correctly. The emphasis was on practical trial-and-error coverage rather than design feedback.",
     "El trabajo fue functional QA puro: probar repetidamente comportamiento esperado, reproducir incidencias y comprobar que personajes, misiones, desbloqueos y objetos funcionaban correctamente. El foco estaba en cobertura práctica mediante pruebas, no en feedback de diseño."),
    ("This was a targeted support credit rather than a full-production assignment. I contributed when additional testing capacity was needed, so the page keeps the scope explicit while still documenting the commercial title and the systems I validated.",
     "Fue un crédito de soporte puntual y no una asignación de producción completa. Contribuí cuando se necesitaba capacidad adicional de testing, por lo que la página mantiene el alcance explícito mientras documenta el título comercial y los sistemas que validé."),
    ("Public promotional screenshots provide visual context for the characters, objectives, environments and interactions covered by the functional QA pass. Click any image to expand it.",
     "Las capturas promocionales públicas aportan contexto visual a personajes, objetivos, entornos e interacciones cubiertos durante el pase de functional QA. Pulsa cualquier imagen para ampliarla."),

    # Cat in the Hat
    ("Targeted Functional QA on the PC / Steam build during an early beta phase, validating newly integrated content while the project was still evolving and features were continuing to enter production builds.",
     "Functional QA puntual en la build de PC / Steam durante una fase temprana de beta, validando contenido recién integrado mientras el proyecto seguía evolucionando y nuevas funcionalidades entraban en las builds de producción."),
    ("I joined the project during an early beta period and tested only the PC / Steam build. The assignment was focused on new-content validation: testing additions as they entered evolving builds, reproducing functional issues and checking that newly integrated features behaved correctly in the current version.",
     "Me incorporé al proyecto durante una beta temprana y probé únicamente la build de PC / Steam. La asignación se centraba en validar contenido nuevo: probar añadidos a medida que entraban en builds en evolución, reproducir problemas funcionales y comprobar que las funcionalidades recién integradas se comportaban correctamente."),
    ("This page is intentionally scoped to my early-beta QA contribution. It does not imply full-production involvement or ownership of work completed by Casual Brothers, Outright Games or other teams on the project.",
     "Esta página limita deliberadamente el alcance a mi contribución de QA en beta temprana. No implica participación durante toda la producción ni autoría sobre el trabajo realizado por Casual Brothers, Outright Games u otros equipos."),
    ("My contribution was focused exclusively on the PC / Steam build. I worked with beta builds while the project was still evolving and content was continuing to be integrated.",
     "Mi contribución se centró exclusivamente en la build de PC / Steam. Trabajé con builds beta mientras el proyecto seguía evolucionando y continuaba integrándose contenido."),
    ("The builds I worked with were still incomplete, with features and content being added progressively. My role was to validate newly integrated content as it arrived, reproduce functional issues and check that each new addition behaved correctly inside the current build.",
     "Las builds con las que trabajé todavía estaban incompletas y recibían funcionalidades y contenido de forma progresiva. Mi función era validar el contenido recién integrado, reproducir problemas funcionales y comprobar que cada añadido se comportaba correctamente dentro de la build actual."),
    ("Like my Chicken Run: Eggstraction credit, this was targeted Functional QA support rather than a full-production assignment. The focus here was specifically early-beta coverage and new-content validation on Steam.",
     "Al igual que en Chicken Run: Eggstraction, se trató de soporte puntual de Functional QA y no de una asignación de producción completa. El foco estaba específicamente en cobertura de beta temprana y validación de contenido nuevo en Steam."),
    ("Public promotional screenshots show the variety of minigames and multiplayer contexts surrounding the kind of evolving content being integrated during development. Click any image to expand it.",
     "Las capturas promocionales públicas muestran la variedad de minijuegos y contextos multijugador alrededor del tipo de contenido que se integraba durante el desarrollo. Pulsa cualquier imagen para ampliarla."),
]

def translate_text_es(text):
    stripped = text.strip()
    if not stripped:
        return text
    if stripped in ES_EXACT:
        translated = ES_EXACT[stripped]
        return text.replace(stripped, translated)
    result = text
    for source, target in sorted(ES_PHRASES, key=lambda pair: len(pair[0]), reverse=True):
        result = result.replace(source, target)
    return result

def translate_visible_es(html):
    protected = re.compile(r'(<script\b[\s\S]*?</script>|<style\b[\s\S]*?</style>|<pre\b[\s\S]*?</pre>|<code\b[\s\S]*?</code>|<[^>]+>)', re.I)
    parts = protected.split(html)
    for i, part in enumerate(parts):
        if not part.startswith("<"):
            parts[i] = translate_text_es(part)
    html = "".join(parts)

    # Translate accessible labels and alt text without touching URLs/data.
    def attr_translate(match):
        return match.group(1) + translate_text_es(match.group(2)) + match.group(3)
    html = re.sub(r'((?:alt|aria-label|title)=")([^"]*)(")', attr_translate, html)

    # Spanish document semantics and shared assets one directory up.
    html = html.replace('<html lang="en">','<html lang="es">',1)
    html = html.replace('href="style.css"','href="../style.css"',1)
    html = html.replace('href="Pedro-Pinczura-CV.pdf"','href="../Pedro-Pinczura-CV.pdf"')
    html = html.replace('src="public/','src="../public/')
    html = html.replace('href="public/','href="../public/')
    html = html.replace('data-src="public/','data-src="../public/')
    return html

ES_META = {
    "index.html":("Pedro Pinczura — Technical Designer","Technical Designer con experiencia en diseño, gameplay programming, Unity, Unreal y Functional QA."),
    "work.html":("Proyectos — Pedro Pinczura","Casos de estudio y proyectos de Technical Design, gameplay y sistemas de Pedro Pinczura."),
    "credits.html":("Créditos profesionales — Pedro Pinczura","Créditos comerciales con contribuciones claramente delimitadas en QA, gameplay y feedback de diseño."),
    "about.html":("Sobre mí — Pedro Pinczura","Perfil, experiencia, stack técnico y recorrido multidisciplinar de Pedro Pinczura como Technical Designer."),
    "contact.html":("Contacto — Pedro Pinczura","Contacto profesional de Pedro Pinczura para oportunidades en desarrollo de videojuegos."),
    "paperly.html":("PAPERly — Pedro Pinczura","Caso de estudio de PAPERly: vuelo arcade, control táctil, tuning, progresión y Technical Design en Unity."),
    "bandit-trail.html":("Bandit Trail — Pedro Pinczura","Caso de estudio de Bandit Trail, infinite runner / shooter original desarrollado en Unreal Engine 4."),
    "kids-table.html":("KIDS'TABLE — Pedro Pinczura","Technical Design y Lead Programming en juegos educativos y sistemas interactivos para KIDS'TABLE."),
    "rpg-systems.html":("RPG Systems — Pedro Pinczura","Proyecto personal de sistemas RPG conectados en Unity."),
    "survival-systems.html":("Survival Systems — Pedro Pinczura","Proyecto personal de sistemas de supervivencia, crafting, IA y persistencia en Unity."),
    "nba-bounce.html":("NBA BOUNCE — Crédito profesional — Pedro Pinczura","Functional QA, validación y feedback de gameplay durante el ciclo completo de producción de NBA BOUNCE."),
    "barbie-horse-trails.html":("Barbie Horse Trails — Crédito profesional — Pedro Pinczura","Functional QA y feedback de UX/gameplay durante el ciclo completo de producción de Barbie Horse Trails."),
    "dayz.html":("DayZ — Crédito profesional — Pedro Pinczura","Functional QA en PC / Steam centrado en armas, equipamiento, objetos, animaciones y balance."),
    "chicken-run-eggstraction.html":("Chicken Run: Eggstraction — Crédito profesional — Pedro Pinczura","Soporte puntual de Functional QA en Steam, Nintendo Switch y PlayStation 5."),
    "the-cat-in-the-hat-rainy-day-mayhem.html":("The Cat in the Hat — Crédito profesional — Pedro Pinczura","Functional QA puntual durante una fase temprana de beta en PC / Steam."),
}

def apply_es_meta(html, page):
    title, desc = ES_META[page]
    html = re.sub(r'<title>.*?</title>', f'<title>{title}</title>', html, count=1, flags=re.S)
    if re.search(r'<meta name="description" content="[^"]*">', html):
        html = re.sub(r'<meta name="description" content="[^"]*">', f'<meta name="description" content="{desc}">', html, count=1)
    else:
        html = html.replace('<meta name="theme-color"', f'<meta name="description" content="{desc}">\n  <meta name="theme-color"',1)
    html = re.sub(r'<meta property="og:title" content="[^"]*">', f'<meta property="og:title" content="{title}">', html)
    html = re.sub(r'<meta property="og:description" content="[^"]*">', f'<meta property="og:description" content="{desc}">', html)
    return html

ES_COMMON_CREDIT = {
    "PROFESSIONAL CREDIT / FULL PRODUCTION":"CRÉDITO PROFESIONAL / PRODUCCIÓN COMPLETA",
    "PROFESSIONAL CREDIT / ADDITIONAL CONTENT QA":"CRÉDITO PROFESIONAL / QA DE CONTENIDO ADICIONAL",
    "PROFESSIONAL CREDIT / TARGETED QA SUPPORT":"CRÉDITO PROFESIONAL / SOPORTE QA PUNTUAL",
    "PROFESSIONAL CREDIT / EARLY BETA QA":"CRÉDITO PROFESIONAL / QA EN BETA TEMPRANA",
    "OFFICIAL ARTWORK / PROFESSIONAL CREDIT":"ARTE OFICIAL / CRÉDITO PROFESIONAL",
    "OFFICIAL MEDIA / PROFESSIONAL CREDIT":"MATERIAL OFICIAL / CRÉDITO PROFESIONAL",
    "Early production → release":"Producción temprana → lanzamiento",
    "Scoped additional-content QA":"QA específico de contenido adicional",
    "Targeted production support":"Soporte puntual de producción",
    "Early beta / targeted support":"Beta temprana / soporte puntual",
    "Functional testing":"Testing funcional",
    "Cross-platform QA":"QA multiplataforma",
    "Regression testing":"Testing de regresión",
    "Bug reporting & verification":"Reporte y verificación de bugs",
    "Bug reproduction & verification":"Reproducción y verificación de bugs",
    "Bug reproduction & reporting":"Reproducción y reporte de bugs",
    "NBA rules validation":"Validación de reglas NBA",
    "Gameplay / design feedback":"Feedback de gameplay / diseño",
    "UI / UX feedback":"Feedback de UI / UX",
    "Navigation & mission-flow feedback":"Feedback de navegación y flujo de misiones",
    "English developer communication":"Comunicación con el estudio en inglés",
    "Weapon balancing & validation":"Balance y validación de armas",
    "Equipment / item QA":"QA de equipamiento / objetos",
    "Animation-state validation":"Validación de estados de animación",
    "Traversal edge-case testing":"Testing de casos límite de traversal",
    "English QA workflow":"Flujo de QA en inglés / polaco",
    "Mission validation":"Validación de misiones",
    "Character behaviour QA":"QA de comportamiento de personajes",
    "Unlock / progression checks":"Comprobación de desbloqueos / progresión",
    "Item validation":"Validación de objetos",
    "New content validation":"Validación de contenido nuevo",
    "Early-build verification":"Verificación de builds tempranas",
    "Feature behaviour checks":"Comprobación de comportamiento de funcionalidades",
    "Design Feedback":"Feedback de diseño",
    "Design / UX Feedback":"Feedback de diseño / UX",
    "Full production cycle":"Ciclo completo de producción",
    "targeted production support":"soporte puntual de producción",
    "early beta":"beta temprana",
    "new content validation":"validación de contenido nuevo",
    "PROFESSIONAL CREDIT":"CRÉDITO PROFESIONAL",
}

ES_PAGE_POLISH = {
    "index.html":{
        "Personal Projects":"Proyectos personales",
        ">PROJECTS<":">PROYECTOS<",
        "PUBLIC BUILD / UE4":"BUILD PÚBLICA / UE4",
    },
    "work.html":{
        "WORK / PEDRO PINCZURA":"PROYECTOS / PEDRO PINCZURA",
    },
    "paperly.html":{
        "Launch timing → flight power":"Timing de lanzamiento → potencia de vuelo",
        "Analog touch steering":"Control táctil analógico",
        "Pointer steering":"Control por puntero",
        "Arcade flight simulation":"Simulación de vuelo arcade",
        "Vortex: mechanic + consequence":"Vórtice: mecánica + consecuencia",
        "One normalized timing value drives both immediate feedback and the actual launch state.":"Un único valor normalizado controla tanto el feedback inmediato como el estado real del lanzamiento.",
        "Dead zone + normalization + smoothing gives analog control without a visible joystick.":"Zona muerta + normalización + suavizado permiten control analógico sin un joystick visible.",
        "Forward motion and vertical motion remain separately tuneable before being combined.":"El movimiento frontal y el vertical siguen siendo ajustables por separado antes de combinarse.",
        "The boost compensates a falling plane, then makes future gravity slightly harsher to avoid endless free height.":"El boost compensa un avión en caída y después endurece ligeramente la gravedad futura para evitar altura gratuita infinita.",
        "LAUNCH POWER":"POTENCIA DE LANZAMIENTO",
        "Oscillate from 0 → 1":"Oscila de 0 → 1",
        "Freeze the selected value":"Congela el valor seleccionado",
        "Convert to launch power":"Convierte a potencia de lanzamiento",
        "Audio + partículas + camera shake":"Audio + partículas + sacudida de cámara",
        "READABILITY":"LEGIBILIDAD",
        "CAMERA":"CÁMARA",
        ">VIEW ↗<":">VER ↗<",
        "Main menu: best distance, next goal and reward loop.":"Menú principal: mejor distancia, siguiente objetivo y bucle de recompensa.",
        "Progression upgrades alter core flight parameters.":"Las mejoras de progresión modifican parámetros clave del vuelo.",
        "Cosmetic progression and preview flow.":"Progresión cosmética y flujo de previsualización.",
        "Run results, earnings and record feedback.":"Resultados de la partida, ganancias y feedback de récord.",
        "Settings and reset-progress controls.":"Ajustes y controles para reiniciar el progreso.",
        "Main menu with best distance, goal and reward":"Menú principal con mejor distancia, objetivo y recompensa",
        "Power, Glide, Control and Earnings upgrade screen":"Pantalla de mejoras de Power, Glide, Control y Earnings",
        "Cosmetic skin preview and purchase flow":"Previsualización y compra de skins",
        "Flight results with new-record celebration":"Resultados de vuelo con celebración de nuevo récord",
        "Settings and reset-progress screen":"Pantalla de ajustes y reinicio de progreso",
        "PAPERly main menu":"Menú principal de PAPERly",
        "PAPERly upgrades menu":"Menú de mejoras de PAPERly",
        "PAPERly neon skin preview":"Previsualización de skin neon de PAPERly",
        "PAPERly new record results":"Resultados de nuevo récord de PAPERly",
        "PAPERly settings screen":"Pantalla de ajustes de PAPERly",
        "Full terrain and vortex layout inside Unity.":"Distribución completa del terreno y los vórtices dentro de Unity.",
        "Plane, trails and vortex setup inside Scene view.":"Configuración del avión, trails y vórtices dentro de Scene View.",
        "Out-of-bounds safety flow and warning state.":"Flujo de seguridad fuera de límites y estado de advertencia.",
        "A COMPLETE RUN LOOP,":"UN BUCLE DE PARTIDA COMPLETO,",
        "READY FOR MORE CONTENT.":"LISTO PARA MÁS CONTENIDO.",
        "← ALL PROJECTS":"← TODOS LOS PROYECTOS",
    },
    "bandit-trail.html":{
        "Play / Download ↗":"Jugar / Descargar ↗",
        "Play / Download":"Jugar / Descargar",
        "PLAYABLE.":"DISPONIBLE PARA JUGAR.",
        "Watch trailer ↗":"Ver tráiler ↗",
        "PUBLIC BUILD / UE4":"BUILD PÚBLICA / UE4",
        "RUN. SHOOT.":"CORRE. DISPARA.",
        ">TEAM<":">EQUIPO<",
        "Design direction":"Dirección de diseño",
        "RETHINKING THE":"REPLANTEANDO EL",
        "INFINITE RUNNER.":"INFINITE RUNNER.",
        "RUN. REACT.":"CORRE. REACCIONA.",
        ">Run<":">Correr<",
        ">Dodge<":">Esquivar<",
        ">Fight<":">Combatir<",
        ">Unlock<":">Desbloquear<",
        ">Run Again<":">Volver a correr<",
        "SHAPE THE RUN.":"DEFINEN LA PARTIDA.",
        "FREE MOVEMENT":"MOVIMIENTO LIBRE",
        "SHOOTING":"DISPAROS",
        "ENEMY ENCOUNTERS":"ENCUENTROS CON ENEMIGOS",
        "PROCEDURAL ENVIRONMENTS":"ENTORNOS PROCEDURALES",
        ">Development<":">Desarrollo<",
        "FROM UNIVERSITY PROJECT TO PUBLIC BUILD.":"DE PROYECTO UNIVERSITARIO A BUILD PÚBLICA.",
        "Public playtesting":"Playtesting público",
        "BUILD. RELEASE. LISTEN. ITERATE.":"CONSTRUYE. PUBLICA. ESCUCHA. ITERA.",
        "Western town environment and low-poly visual direction":"Entorno de pueblo del oeste y dirección visual low-poly",
        ">Release<":">Lanzamiento<",
        "PUBLICLY PLAYABLE.":"JUGABLE PÚBLICAMENTE.",
        "Project notes":"Notas del proyecto",
        "Open public project ↗":"Abrir proyecto público ↗",
        "Shared ownership":"Responsabilidad compartida",
        "DESIGNED & DEVELOPED TOGETHER.":"DISEÑADO Y DESARROLLADO JUNTOS.",
        "← ALL PROJECTS":"← TODOS LOS PROYECTOS",
        "NEXT PROJECT":"SIGUIENTE PROYECTO",
    },
    "kids-table.html":{
        "Official product ↗":"Producto oficial ↗",
        "THE PRODUCT":"EL PRODUCTO",
        "SELECTED MINI-GAMES":"MINIJUEGOS SELECCIONADOS",
        "Cooperative play on the physical KIDS&#x27;TABLE hardware.":"Juego cooperativo en el hardware físico de KIDS&#x27;TABLE.",
        "Cooperative play on the physical KIDS&#39;TABLE hardware.":"Juego cooperativo en el hardware físico de KIDS&#39;TABLE.",
        "Cooperative play on the physical KIDS'TABLE hardware.":"Juego cooperativo en el hardware físico de KIDS'TABLE.",
        "BACK TO WORK ↗":"VOLVER A PROYECTOS ↗",
    },
    "rpg-systems.html":{
        "← PERSONAL PROJECTS":"← PROYECTOS PERSONALES",
        "PERSONAL PROJECT / CASE STUDY IN PROGRESS":"PROYECTO PERSONAL / CASO DE ESTUDIO EN PREPARACIÓN",
        ">Combat<":">Combate<",
        ">Inventory<":">Inventario<",
        ">Dialogue<":">Diálogo<",
        ">Quests<":">Misiones<",
        ">Shops<":">Tiendas<",
        ">Abilities<":">Habilidades<",
    },
    "survival-systems.html":{
        "← PERSONAL PROJECTS":"← PROYECTOS PERSONALES",
        "PERSONAL PROJECT / CASE STUDY IN PROGRESS":"PROYECTO PERSONAL / CASO DE ESTUDIO EN PREPARACIÓN",
        ">Survival<":">Supervivencia<",
        ">Inventory<":">Inventario<",
        ">Building<":">Construcción<",
        ">AI<":">IA<",
        ">Save System<":">Sistema de guardado<",
    },
    "nba-bounce.html":{
        "Functional QA · Design Feedback":"Functional QA · Feedback de diseño",
        "NBA BOUNCE / PROFESSIONAL CREDIT":"NBA BOUNCE / CRÉDITO PROFESIONAL",
        "· Design Feedback · Full production cycle":"· Feedback de diseño · Ciclo completo de producción",
    },
    "barbie-horse-trails.html":{
        "Functional QA · Design / UX Feedback":"Functional QA · Feedback de diseño / UX",
        "PROGRESSION.":"PROGRESIÓN.",
        "BARBIE HORSE TRAILS / PROFESSIONAL CREDIT":"BARBIE HORSE TRAILS / CRÉDITO PROFESIONAL",
        "· Design / UX Feedback · Full production cycle":"· Feedback de diseño / UX · Ciclo completo de producción",
    },
    "dayz.html":{
        "DAYZ / PROFESSIONAL CREDIT":"DAYZ / CRÉDITO PROFESIONAL",
        "DayZ armed player encounter in an open area":"Encuentro armado de un jugador de DayZ en una zona abierta",
        "DayZ player aiming a rifle":"Jugador de DayZ apuntando con un rifle",
        "DayZ player holding a firearm":"Jugador de DayZ sosteniendo un arma de fuego",
        "DayZ player in a forest environment":"Jugador de DayZ en un entorno boscoso",
        "DayZ player with a weapon in an urban environment":"Jugador de DayZ con un arma en un entorno urbano",
        "DayZ combat scene":"Escena de combate de DayZ",
        "DayZ player using a firearm":"Jugador de DayZ usando un arma de fuego",
        "DayZ armed character":"Personaje armado de DayZ",
        "DayZ weapon gameplay":"Gameplay de armas de DayZ",
    },
    "chicken-run-eggstraction.html":{
        "CHICKEN RUN: EGGSTRACTION / PROFESSIONAL CREDIT":"CHICKEN RUN: EGGSTRACTION / CRÉDITO PROFESIONAL",
    },
    "the-cat-in-the-hat-rainy-day-mayhem.html":{
        "Functional QA · New Content Validation":"Functional QA · Validación de contenido nuevo",
        "THE CAT IN THE HAT: RAINY DAY MAYHEM / PROFESSIONAL CREDIT":"THE CAT IN THE HAT: RAINY DAY MAYHEM / CRÉDITO PROFESIONAL",
    },
}

def apply_es_polish(html, page):
    if page in ("nba-bounce.html","barbie-horse-trails.html","dayz.html","chicken-run-eggstraction.html","the-cat-in-the-hat-rainy-day-mayhem.html"):
        for source, target in ES_COMMON_CREDIT.items():
            html = html.replace(source, target)
    for source, target in ES_PAGE_POLISH.get(page, {}).items():
        html = html.replace(source, target)
    return html

es_dir = Path("dist/es")
es_dir.mkdir(parents=True, exist_ok=True)
for page in bilingual_pages:
    source = Path("dist") / page
    target = es_dir / page
    translated = translate_visible_es(source.read_text(encoding="utf-8"))
    translated = apply_es_meta(translated, page)
    translated = apply_es_polish(translated, page)
    target.write_text(translated, encoding="utf-8")

def add_language_toggle(path, page, spanish=False):
    p = Path(path)
    html = p.read_text(encoding="utf-8")
    if "lang-toggle" in html:
        return
    if spanish:
        toggle = f'<span class="lang-toggle" aria-label="Idioma"><a class="lang-flag" href="../{page}" hreflang="en" lang="en" aria-label="English" title="English">🇬🇧</a><b class="lang-flag is-active" aria-current="true" aria-label="Español" title="Español">🇪🇸</b></span>'
        alternate = f'<link rel="alternate" hreflang="en" href="../{page}"><link rel="alternate" hreflang="es" href="{page}">'
    else:
        toggle = f'<span class="lang-toggle" aria-label="Language"><b class="lang-flag is-active" aria-current="true" aria-label="English" title="English">🇬🇧</b><a class="lang-flag" href="es/{page}" hreflang="es" lang="es" aria-label="Español" title="Español">🇪🇸</a></span>'
        alternate = f'<link rel="alternate" hreflang="en" href="{page}"><link rel="alternate" hreflang="es" href="es/{page}">'
    html = html.replace('<a class="cv"', toggle + '<a class="cv"', 1)
    html = html.replace("</head>", alternate + "</head>", 1)
    p.write_text(html, encoding="utf-8")

def replace_home_mark(path, label):
    p = Path(path)
    html = p.read_text(encoding="utf-8")
    # Replace only links whose complete visible content is the old "PP" mark.
    html = re.sub(
        r'(<a\\b[^>]*>)(\\s*)PP(\\s*)(</a>)',
        lambda m: m.group(1) + m.group(2) + label + m.group(3) + m.group(4),
        html
    )
    p.write_text(html, encoding="utf-8")

for page in bilingual_pages:
    add_language_toggle(Path("dist") / page, page, spanish=False)
    add_language_toggle(Path("dist/es") / page, page, spanish=True)
    replace_home_mark(Path("dist") / page, "HOME")
    replace_home_mark(Path("dist/es") / page, "INICIO")

# Spanish-only editorial fixes for layouts whose English line breaks do not translate well.
home_es = Path("dist/es/index.html")
home_text = home_es.read_text(encoding="utf-8")
home_text = home_text.replace(
    '<div class="ey">Créditos profesionales</div><strong>CRÉDITOS<br>CRÉDITOS</strong>',
    '<div class="ey">Créditos profesionales</div><strong>CRÉDITOS<br>PROFESIONALES.</strong>'
)
home_es.write_text(home_text, encoding="utf-8")

css = Path("dist/style.css")
css.write_text(css.read_text(encoding="utf-8") + r'''

/* ===== V18 language switch ===== */
.lang-toggle{
  display:inline-flex;
  align-items:center;
  gap:6px;
  padding:4px 6px;
  border:1px solid rgba(255,255,255,.12);
  background:rgba(255,255,255,.025);
}
.lang-flag{
  display:inline-grid;
  place-items:center;
  min-width:24px;
  min-height:22px;
  padding:1px 2px;
  border:1px solid transparent;
  border-radius:3px;
  opacity:.55;
  text-decoration:none;
  font-size:16px;
  line-height:1;
  filter:saturate(.7);
  transition:opacity .2s,border-color .2s,filter .2s,transform .2s;
}
.lang-flag.is-active{
  opacity:1;
  border-color:rgba(255,255,255,.28);
  filter:saturate(1);
}
a.lang-flag:hover,
a.lang-flag:focus-visible{
  opacity:1;
  border-color:var(--b2);
  filter:saturate(1);
  transform:translateY(-1px);
}
@media(max-width:720px){
  .lang-toggle{
    margin-top:4px;
    align-self:flex-start;
  }
}
''', encoding="utf-8")

# ===== Recruiter scan emphasis pass =====
# Add restrained emphasis inside paragraphs so recruiters can scan role, technology,
# ownership, systems and production scope without turning the page into bold noise.
def emphasize_paragraphs(path, phrases):
    p = Path(path)
    html = p.read_text(encoding="utf-8")
    ordered = list(dict.fromkeys(phrases))

    def transform(match):
        attrs = match.group(1) or ""
        body = match.group(2)
        tokens = []

        for phrase in ordered:
            escaped = re.escape(phrase)
            prefix = r"(?<![A-Za-z0-9])" if phrase[:1].isalnum() else ""
            suffix = r"(?![A-Za-z0-9])" if phrase[-1:].isalnum() else ""
            pattern = prefix + escaped + suffix

            if re.search(pattern, body):
                token = f"__SCANKEY_{len(tokens)}__"
                body = re.sub(pattern, token, body, count=1)
                tokens.append((token, phrase))

        for token, phrase in tokens:
            body = body.replace(token, f'<strong class="scan-key">{phrase}</strong>')

        return f"<p{attrs}>{body}</p>"

    html = re.sub(r"<p([^>]*)>([\s\S]*?)</p>", transform, html)
    p.write_text(html, encoding="utf-8")

emphasis = {
    "dist/index.html": [
        "Technical Designer", "Unity / C#", "Unreal / Blueprints", "Functional QA",
        "gameplay systems", "commercial production", "Technical Design",
        "end-to-end development", "commercial QA", "Custom flight model",
        "touch steering", "environmental boosts", "progression",
        "Design, C# implementation", "coordination",
        "Full-cycle, multi-platform Functional QA", "licensed-content validation",
        "direct studio communication in English", "concept to public release",
        "player feedback", "technical design", "gameplay implementation",
        "technical experiments", "contribution scope", "Technical Design profile",
        "Game Design", "Gameplay Programming", "Unity / Unreal development",
        "entry-level Production"
    ],
    "dist/work.html": [
        "gameplay", "implementation", "iteration", "production",
        "Design, development, playtesting and iteration",
        "Technical Design, implementation and coordination",
        "Custom flight model", "touch steering", "vortices", "upgrades",
        "full case study coming soon"
    ],
    "dist/credits.html": [
        "Professional game credits", "clear contribution scopes",
        "tested, validated or contributed"
    ],
    "dist/about.html": [
        "Technical Designer", "game design", "gameplay programming", "functional QA",
        "Technical Design", "Game Design", "Gameplay Programming",
        "Unity / Unreal development", "entry-level Production",
        "meaningful parameters for iteration", "design intent into working systems",
        "tuned, tested, documented and maintained", "iteration and playtesting",
        "Unity / C#", "Unreal Engine / Blueprints", "Functional testing",
        "bug analysis", "design feedback", "technical implementation",
        "player should experience", "iterated quickly", "Multi-platform functional QA",
        "gameplay / UX feedback", "Design and implementation",
        "technical documentation", "Functional QA in English",
        "weapons, equipment, items", "UE4 endless runner",
        "public demos", "player feedback", "Production"
    ],
    "dist/contact.html": [
        "Technical Design", "Game Design", "Gameplay Programming",
        "design, programming and QA", "Production",
        "email or LinkedIn"
    ],
    "dist/paperly.html": [
        "mobile arcade flight prototype", "launch timing", "custom flight tuning",
        "touch steering", "environmental boosts", "progression",
        "skill-based", "intentionally tunable", "underlying flight model",
        "custom gravity", "progressive speed", "terminal descent",
        "dead zone", "normalized distance", "smoothing",
        "fall compensation", "gravity penalty", "Power, Glide and Control upgrades",
        "dynamic FOV", "design logic", "serialized parameters",
        "iteration visible and fast", "normalized value", "game state and cooldown",
        "LateUpdate", "Rigidbody", "Visual pitch and roll",
        "run-level gravity penalty", "timed warning", "vertical mobile viewport",
        "native portrait composition", "implementation context",
        "one repeatable mobile loop"
    ],
    "dist/bandit-trail.html": [
        "infinite runner / shooter", "free movement", "combat", "enemy encounters",
        "changing environments", "public release", "player-driven iteration",
        "more agency", "infinite-runner formula", "same goal",
        "Ranged combat", "Armed enemies", "procedurally generated maps",
        "unlockable weapons and character skins", "design, implementation, integration, testing and iteration",
        "free playable builds", "external players", "user-driven iteration",
        "publicly downloadable", "verifiable record", "created from zero",
        "publicly playable release"
    ],
    "dist/kids-table.html": [
        "Technical Design", "Lead Programming", "educational mini-games",
        "interactive systems", "Unity / C#", "more than 150 educational applications",
        "hands-on C# programming", "technical decisions", "coordination with external programmers",
        "approximately 90% of the mini-games", "initial concept through implementation and final delivery",
        "design intent and implementation", "target hardware", "ready to ship"
    ],
    "dist/rpg-systems.html": [
        "personal Unity project", "combat", "inventory", "dialogue", "quests",
        "shops", "abilities", "player progression loop", "full case study",
        "implementation details"
    ],
    "dist/survival-systems.html": [
        "survival prototype", "player needs", "inventory", "resource gathering",
        "crafting", "base building", "NPC combat", "save/load systems",
        "NPC AI", "persistence", "full case study", "implementation details"
    ],
    "dist/nba-bounce.html": [
        "Full-cycle functional QA", "console and PC builds", "cross-platform regression",
        "bug reporting and verification", "licensed-content validation",
        "gameplay/design feedback", "full production cycle",
        "reproducing and classifying issues", "validating fixes",
        "Nintendo Switch, PlayStation 5 and Steam", "functional QA",
        "gameplay-focused observations", "edge cases", "animation flow",
        "shot behaviour", "sprint speed", "shot-meter timing",
        "aerial catch-to-dunk sequence"
    ],
    "dist/barbie-horse-trails.html": [
        "Full-cycle functional QA", "console and PC builds", "cross-platform regression",
        "bug reporting and verification", "gameplay and UX feedback",
        "interface clarity", "world navigation", "mission progression",
        "full production cycle", "US-based development studio in English",
        "Nintendo Switch, PlayStation 5 and Steam", "functional QA",
        "UX and gameplay feedback", "backtracking", "shortcuts, teleports and fast-travel"
    ],
    "dist/dayz.html": [
        "PC / Steam functional QA", "weapons, equipment and items",
        "balance and behaviour validation", "dedicated combat test environment",
        "functional validation", "weapon behaviour and balance",
        "animation and traversal coverage", "Steam build", "dedicated scenario"
    ],
    "dist/chicken-run-eggstraction.html": [
        "functional QA support", "Steam, Nintendo Switch and PlayStation 5",
        "characters, missions, unlocks, items and progression",
        "pure functional QA", "practical trial-and-error testing",
        "targeted QA contribution", "additional functional coverage"
    ],
    "dist/the-cat-in-the-hat-rainy-day-mayhem.html": [
        "Targeted Functional QA", "PC / Steam build", "early beta phase",
        "newly integrated content", "new-content validation",
        "reproducing functional issues", "early-beta QA contribution",
        "beta builds", "content was continuing to be integrated"
    ],
}

for page, phrases in emphasis.items():
    emphasize_paragraphs(page, phrases)

emphasis_es = {
    "dist/es/index.html":[
        "Technical Designer","Unity / C#","Unreal / Blueprints","Functional QA",
        "sistemas de gameplay","feedback de jugadores","producción comercial",
        "Technical Design","desarrollo end-to-end","QA comercial",
        "modelo de vuelo personalizado","control táctil","coordinación"
    ],
    "dist/es/about.html":[
        "Technical Designer","diseño de juego","gameplay programming","functional QA",
        "Technical Design","Game Design","Gameplay Programming","Unity / C#",
        "Unreal Engine / Blueprints","testing funcional","análisis de bugs",
        "implementación técnica","iterarse rápido"
    ],
    "dist/es/contact.html":[
        "Technical Design","Game Design","Gameplay Programming",
        "diseño, programación y QA","Production","email o LinkedIn"
    ],
    "dist/es/paperly.html":[
        "prototipo móvil de vuelo arcade","timing de lanzamiento","control táctil",
        "boosts ambientales","progresión","modelo de vuelo base","gravedad personalizada",
        "velocidad progresiva","zona muerta","FOV dinámico","parámetros serializados",
        "LateUpdate","Rigidbody","vórtices","viewport móvil vertical"
    ],
    "dist/es/bandit-trail.html":[
        "Infinite runner / shooter original","movimiento libre","combate",
        "lanzamiento público","feedback de jugadores","mapas generados proceduralmente",
        "builds jugables gratuitas","iteración guiada por usuarios"
    ],
    "dist/es/kids-table.html":[
        "Technical Design","Lead Programming","minijuegos educativos","Unity / C#",
        "programación directa en C#","aproximadamente el 90%","hardware objetivo"
    ],
    "dist/es/rpg-systems.html":[
        "Proyecto personal en Unity","combate","inventario","diálogo","misiones",
        "habilidades","bucle de progresión"
    ],
    "dist/es/survival-systems.html":[
        "Prototipo de supervivencia","inventario","crafting","construcción",
        "IA","persistencia"
    ],
    "dist/es/nba-bounce.html":[
        "Functional QA","ciclo de producción","regresión multiplataforma",
        "validación de contenido licenciado","feedback de gameplay","Nintendo Switch",
        "PlayStation 5","Steam","casos límite"
    ],
    "dist/es/barbie-horse-trails.html":[
        "Functional QA","ciclo de producción","regresión multiplataforma",
        "feedback de gameplay y UX","Nintendo Switch","PlayStation 5","Steam",
        "backtracking","viaje rápido"
    ],
    "dist/es/dayz.html":[
        "Functional QA","PC / Steam","armas, equipamiento y objetos",
        "balance de armas","build de Steam","escenario dedicado"
    ],
    "dist/es/chicken-run-eggstraction.html":[
        "functional QA","Steam, Nintendo Switch y PlayStation 5",
        "personajes, misiones","progresión","cobertura adicional"
    ],
    "dist/es/the-cat-in-the-hat-rainy-day-mayhem.html":[
        "Functional QA","PC / Steam","beta temprana","contenido nuevo",
        "problemas funcionales"
    ],
}
for page, phrases in emphasis_es.items():
    emphasize_paragraphs(page, phrases)

css = Path("dist/style.css")
css.write_text(css.read_text(encoding="utf-8") + r'''

/* ===== Recruiter scan emphasis ===== */
.scan-key{
  display:inline!important;
  color:#ffffff!important;
  font-family:inherit!important;
  font-size:inherit!important;
  font-style:inherit!important;
  font-weight:inherit!important;
  line-height:inherit!important;
  letter-spacing:inherit!important;
  text-transform:inherit!important;
  vertical-align:baseline!important;
  white-space:inherit!important;
  -webkit-text-stroke:.32px currentColor;
  text-shadow:0 0 .28px currentColor;
}
''', encoding="utf-8")


# ===== Steam-style portfolio galleries =====
from html import escape as html_escape

def _attr(tag, name):
    m = re.search(rf'{re.escape(name)}="([^"]*)"', tag)
    return m.group(1) if m else ""

def _thumb_src(src):
    # Bandit Trail cover has no dedicated thumb in this bundle; its source is already small.
    if src in ("public/media/bandit-trail/cover.webp","../public/media/bandit-trail/cover.webp"):
        return src
    prefix = "public/media/"
    es_prefix = "../public/media/"
    if src.startswith(prefix):
        return "public/media/thumbs/" + src[len(prefix):]
    if src.startswith(es_prefix):
        return "../public/media/thumbs/" + src[len(es_prefix):]
    return src

def _steam_markup(items):
    if not items:
        return ""
    thumbs = []
    for i, item in enumerate(items):
        selected = " is-active" if i == 0 else ""
        thumbs.append(
            f'<button type="button" class="steam-thumb{selected}" data-index="{i}" '
            f'aria-label="Show image {i+1} of {len(items)}">'
            f'<img src="{html_escape(_thumb_src(item["src"]), quote=True)}" '
            f'alt="{html_escape(item["alt"], quote=True)}" loading="lazy" decoding="async"></button>'
        )
    data = []
    for item in items:
        data.append(
            '<span class="steam-data" '
            f'data-src="{html_escape(item["src"], quote=True)}" '
            f'data-alt="{html_escape(item["alt"], quote=True)}" '
            f'data-caption="{html_escape(item["caption"], quote=True)}"></span>'
        )
    first = items[0]
    return f'''
<div class="steam-gallery" data-steam-gallery>
  <div class="steam-stage">
    <button type="button" class="steam-nav steam-prev" aria-label="Previous image">‹</button>
    <button type="button" class="steam-main" aria-label="Open image at full size">
      <img src="{html_escape(first["src"], quote=True)}" alt="{html_escape(first["alt"], quote=True)}">
    </button>
    <button type="button" class="steam-nav steam-next" aria-label="Next image">›</button>
  </div>
  <div class="steam-meta">
    <p class="steam-caption">{html_escape(first["caption"])}</p>
    <span class="steam-count">1 / {len(items)}</span>
  </div>
  <div class="steam-thumbs" aria-label="Gallery thumbnails">
    {''.join(thumbs)}
  </div>
  <div class="steam-dataset" hidden>{''.join(data)}</div>
</div>'''

def _extract_button_items(block):
    items = []
    for bm in re.finditer(r'<button\b[^>]*>[\s\S]*?</button>', block):
        button = bm.group(0)
        om = re.match(r'<button\b[^>]*>', button)
        im = re.search(r'<img\b[^>]*>', button)
        if not om or not im:
            continue
        open_tag = om.group(0)
        img_tag = im.group(0)
        src = _attr(open_tag, "data-src") or _attr(img_tag, "src")
        alt = _attr(img_tag, "alt")
        caption = _attr(open_tag, "data-caption") or alt
        if src:
            items.append({"src":src, "alt":alt, "caption":caption})
    return items

def _extract_figure_items(block):
    items = []
    for fm in re.finditer(r'<figure\b[^>]*>[\s\S]*?</figure>', block):
        fig = fm.group(0)
        im = re.search(r'<img\b[^>]*>', fig)
        if not im:
            continue
        img_tag = im.group(0)
        src = _attr(img_tag, "src")
        alt = _attr(img_tag, "alt")
        cm = re.search(r'<figcaption>([\s\S]*?)</figcaption>', fig)
        caption = re.sub(r'<[^>]+>', '', cm.group(1)).strip() if cm else alt
        if src:
            items.append({"src":src, "alt":alt, "caption":caption})
    return items

def transform_credit_gallery(path):
    p = Path(path)
    html = p.read_text(encoding="utf-8")
    pattern = re.compile(r'(<div class="ghead">[\s\S]*?</div>)<div class="gallery">([\s\S]*?)</div></div></section>')
    m = pattern.search(html)
    if not m:
        raise SystemExit(f"Credit gallery not found in {path}")
    items = _extract_button_items(m.group(2))
    replacement = m.group(1) + _steam_markup(items) + '</div></section>'
    html = html[:m.start()] + replacement + html[m.end():]
    p.write_text(html, encoding="utf-8")

def transform_bandit_gallery(path):
    p = Path(path)
    html = p.read_text(encoding="utf-8")
    pattern = re.compile(r'(<section class="c gallerysec bt-gallery"><div class="galleryhead">[\s\S]*?</div>)<div class="gallerygrid">([\s\S]*?)</div></section>')
    m = pattern.search(html)
    if not m:
        raise SystemExit(f"Bandit gallery not found in {path}")
    items = _extract_button_items(m.group(2))
    replacement = m.group(1) + _steam_markup(items) + '</section>'
    html = html[:m.start()] + replacement + html[m.end():]
    p.write_text(html, encoding="utf-8")

def transform_kids_gallery(path):
    p = Path(path)
    html = p.read_text(encoding="utf-8")
    pattern = re.compile(r'(<section class="c gallerysec"><div class="galleryhead">[\s\S]*?</div>)<div class="gallerygrid">([\s\S]*?)</div></section>')
    m = pattern.search(html)
    if not m:
        raise SystemExit(f"KIDS TABLE gallery not found in {path}")
    items = _extract_figure_items(m.group(2))
    replacement = m.group(1) + _steam_markup(items) + '</section>'
    html = html[:m.start()] + replacement + html[m.end():]
    p.write_text(html, encoding="utf-8")

for gallery_page in ["dist/bandit-trail.html","dist/es/bandit-trail.html"]:
    transform_bandit_gallery(gallery_page)
for gallery_page in ["dist/kids-table.html","dist/es/kids-table.html"]:
    transform_kids_gallery(gallery_page)
for gallery_page in [
    "dist/nba-bounce.html","dist/es/nba-bounce.html",
    "dist/barbie-horse-trails.html","dist/es/barbie-horse-trails.html",
    "dist/dayz.html","dist/es/dayz.html",
    "dist/chicken-run-eggstraction.html","dist/es/chicken-run-eggstraction.html",
    "dist/the-cat-in-the-hat-rainy-day-mayhem.html","dist/es/the-cat-in-the-hat-rainy-day-mayhem.html",
]:
    transform_credit_gallery(gallery_page)

steam_dialog = '''
<dialog class="steam-lightbox" id="steam-lightbox">
  <button type="button" class="steam-lightbox-close" aria-label="Close image preview">×</button>
  <img src="" alt="">
  <p></p>
</dialog>
'''

steam_script = r'''
<script>
(()=>{
  const galleries=[...document.querySelectorAll('[data-steam-gallery]')];
  if(!galleries.length)return;

  let lightbox=document.getElementById('steam-lightbox');
  if(!lightbox){
    document.body.insertAdjacentHTML('beforeend','<dialog class="steam-lightbox" id="steam-lightbox"><button type="button" class="steam-lightbox-close" aria-label="Close image preview">×</button><img src="" alt=""><p></p></dialog>');
    lightbox=document.getElementById('steam-lightbox');
  }
  const lbImg=lightbox.querySelector('img');
  const lbCap=lightbox.querySelector('p');

  galleries.forEach(gallery=>{
    const data=[...gallery.querySelectorAll('.steam-data')].map(el=>({
      src:el.dataset.src||'',
      alt:el.dataset.alt||'',
      caption:el.dataset.caption||''
    }));
    const main=gallery.querySelector('.steam-main img');
    const caption=gallery.querySelector('.steam-caption');
    const count=gallery.querySelector('.steam-count');
    const thumbs=[...gallery.querySelectorAll('.steam-thumb')];
    let current=0;

    const show=(index,scrollThumb=true)=>{
      current=(index+data.length)%data.length;
      const item=data[current];
      main.src=item.src;
      main.alt=item.alt;
      caption.textContent=item.caption;
      count.textContent=(current+1)+' / '+data.length;
      thumbs.forEach((thumb,i)=>{
        const active=i===current;
        thumb.classList.toggle('is-active',active);
        thumb.setAttribute('aria-current',active?'true':'false');
      });
      if(scrollThumb) thumbs[current]?.scrollIntoView({behavior:'smooth',block:'nearest',inline:'center'});
    };

    gallery.querySelector('.steam-prev')?.addEventListener('click',()=>show(current-1));
    gallery.querySelector('.steam-next')?.addEventListener('click',()=>show(current+1));
    thumbs.forEach((thumb,i)=>thumb.addEventListener('click',()=>show(i,false)));

    gallery.querySelector('.steam-main')?.addEventListener('click',()=>{
      const item=data[current];
      lbImg.src=item.src;
      lbImg.alt=item.alt;
      lbCap.textContent=item.caption;
      lightbox.showModal();
    });

    gallery.addEventListener('keydown',e=>{
      if(e.key==='ArrowLeft'){e.preventDefault();show(current-1)}
      if(e.key==='ArrowRight'){e.preventDefault();show(current+1)}
    });

    let touchStartX=0;
    const stage=gallery.querySelector('.steam-stage');
    stage?.addEventListener('touchstart',e=>{touchStartX=e.changedTouches[0].clientX},{passive:true});
    stage?.addEventListener('touchend',e=>{
      const dx=e.changedTouches[0].clientX-touchStartX;
      if(Math.abs(dx)>45) show(dx<0?current+1:current-1);
    },{passive:true});
  });

  lightbox.querySelector('.steam-lightbox-close')?.addEventListener('click',()=>lightbox.close());
  lightbox.addEventListener('click',e=>{if(e.target===lightbox)lightbox.close()});
})();
</script>
'''

for gallery_page in [
    "dist/bandit-trail.html","dist/es/bandit-trail.html",
    "dist/kids-table.html","dist/es/kids-table.html",
    "dist/nba-bounce.html","dist/es/nba-bounce.html",
    "dist/barbie-horse-trails.html","dist/es/barbie-horse-trails.html",
    "dist/dayz.html","dist/es/dayz.html",
    "dist/chicken-run-eggstraction.html","dist/es/chicken-run-eggstraction.html",
    "dist/the-cat-in-the-hat-rainy-day-mayhem.html","dist/es/the-cat-in-the-hat-rainy-day-mayhem.html",
]:
    p = Path(gallery_page)
    html = p.read_text(encoding="utf-8")
    if 'id="steam-lightbox"' not in html:
        html = html.replace("</main>", steam_dialog + "</main>")
    html = html.replace("</body>", steam_script + "</body>")
    p.write_text(html, encoding="utf-8")

css = Path("dist/style.css")
css.write_text(css.read_text(encoding="utf-8") + r'''

/* ===== Steam-style portfolio galleries ===== */
.steam-gallery{margin-top:30px}
.steam-stage{
  position:relative;
  display:grid;
  place-items:center;
  min-height:clamp(360px,52vw,720px);
  overflow:hidden;
  border:1px solid var(--l);
  background:radial-gradient(circle at 50% 44%,rgba(47,128,255,.08),transparent 50%),#070a0e;
}
.steam-main{
  width:100%;
  height:100%;
  min-height:inherit;
  padding:0;
  border:0;
  display:grid;
  place-items:center;
  background:transparent;
  cursor:zoom-in;
}
.steam-main img{
  display:block;
  width:auto;
  height:auto;
  max-width:100%;
  max-height:720px;
  object-fit:contain;
  object-position:center;
  image-rendering:auto;
}
.steam-nav{
  position:absolute;
  top:50%;
  z-index:3;
  width:50px;
  height:74px;
  margin-top:-37px;
  border:1px solid rgba(255,255,255,.18);
  background:rgba(5,8,12,.72);
  color:#fff;
  display:grid;
  place-items:center;
  font-size:42px;
  font-weight:300;
  line-height:1;
  cursor:pointer;
  backdrop-filter:blur(8px);
  transition:background .2s,border-color .2s,transform .2s;
}
.steam-nav:hover,.steam-nav:focus-visible{
  background:rgba(47,128,255,.82);
  border-color:rgba(105,168,255,.8);
}
.steam-prev{left:14px}
.steam-next{right:14px}
.steam-meta{
  min-height:48px;
  display:flex;
  align-items:center;
  justify-content:space-between;
  gap:18px;
  padding:11px 2px 10px;
}
.steam-caption{
  margin:0!important;
  color:#9ba7b6;
  font-size:12px!important;
  line-height:1.45!important;
}
.steam-count{
  flex:0 0 auto;
  color:#718092;
  font:10px ui-monospace,SFMono-Regular,Menlo,Consolas,monospace;
  letter-spacing:.08em;
}
.steam-thumbs{
  display:grid;
  grid-auto-flow:column;
  grid-auto-columns:minmax(132px,1fr);
  gap:9px;
  overflow-x:auto;
  overscroll-behavior-inline:contain;
  scrollbar-width:thin;
  padding:0 0 8px;
  scroll-snap-type:x proximity;
}
.steam-thumb{
  position:relative;
  aspect-ratio:16/9;
  padding:3px;
  border:1px solid var(--l);
  background:#090d12;
  opacity:.62;
  cursor:pointer;
  overflow:hidden;
  scroll-snap-align:center;
  transition:opacity .2s,border-color .2s,box-shadow .2s,transform .2s;
}
.steam-thumb img{
  display:block;
  width:100%;
  height:100%;
  object-fit:cover;
  image-rendering:auto;
}
.steam-thumb:hover{opacity:.9}
.steam-thumb.is-active{
  opacity:1;
  border-color:var(--b2);
  box-shadow:inset 0 0 0 1px var(--b2),0 0 0 1px rgba(105,168,255,.15);
}
.steam-thumb.is-active::after{
  content:"";
  position:absolute;
  left:8px;
  right:8px;
  bottom:0;
  height:2px;
  background:var(--b2);
}
.steam-lightbox{
  width:min(94vw,1500px);
  max-width:none;
  max-height:94vh;
  padding:0;
  border:1px solid rgba(255,255,255,.16);
  background:#05070a;
  color:#fff;
  box-shadow:0 32px 110px rgba(0,0,0,.75);
}
.steam-lightbox::backdrop{
  background:rgba(2,4,7,.9);
  backdrop-filter:blur(8px);
}
.steam-lightbox img{
  display:block;
  width:100%;
  max-height:84vh;
  object-fit:contain;
}
.steam-lightbox p{
  margin:0!important;
  padding:12px 16px 14px;
  border-top:1px solid var(--l);
  color:#9da8b7;
  font-size:12px!important;
}
.steam-lightbox-close{
  position:absolute;
  top:12px;
  right:12px;
  z-index:4;
  width:40px;
  height:40px;
  border:1px solid rgba(255,255,255,.22);
  background:rgba(5,8,12,.82);
  color:#fff;
  font-size:25px;
  cursor:pointer;
}
@media(max-width:760px){
  .steam-stage{min-height:clamp(240px,68vw,430px)}
  .steam-nav{width:40px;height:58px;margin-top:-29px;font-size:34px}
  .steam-prev{left:7px}
  .steam-next{right:7px}
  .steam-thumbs{grid-auto-columns:112px;gap:7px}
  .steam-meta{align-items:flex-start}
}
''', encoding="utf-8")

PY
