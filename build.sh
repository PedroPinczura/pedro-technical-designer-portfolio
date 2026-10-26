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

# ===== Recruiter scan emphasis pass =====
# Add restrained emphasis inside paragraphs so recruiters can scan role, technology,
# ownership, systems and production scope without turning the page into bold noise.
def emphasize_paragraphs(path, phrases):
    p = Path(path)
    html = p.read_text(encoding="utf-8")
    ordered = sorted(dict.fromkeys(phrases), key=len, reverse=True)

    def transform(match):
        body = match.group(1)
        tokens = []
        for phrase in ordered:
            if phrase in body:
                token = f"__SCANKEY_{len(tokens)}__"
                body = body.replace(phrase, token, 1)
                tokens.append((token, phrase))
        for token, phrase in tokens:
            body = body.replace(token, f'<strong class="scan-key">{phrase}</strong>')
        return "<p>" + body + "</p>"

    html = re.sub(r"<p>([\s\S]*?)</p>", transform, html)
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

css = Path("dist/style.css")
css.write_text(css.read_text(encoding="utf-8") + r'''

/* ===== Recruiter scan emphasis ===== */
.scan-key{
  color:#edf4ff;
  font-weight:700;
}
.pp-codefoot .scan-key,
figcaption .scan-key{
  color:inherit;
}
''', encoding="utf-8")

PY
