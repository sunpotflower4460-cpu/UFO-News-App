/* SkyTrace interactive preview logic.
   Renders the SwiftUI screens (Today / Map / Research / Settings + Case detail
   + Paywall) from docs/preview/data.json, which is extracted verbatim from the
   Swift demo fixtures by scripts/extract_fixtures.py. Vanilla JS, no build step. */
"use strict";

const state = { tab: "today", caseID: null, plus: false, mapFilter: "all", query: "", sheet: false };
let DATA = null, CASES = {}, LEGAL = "../site/";

// ---- fixture clock (FixtureClock.today = 2026-07-13 22:40) ----
const AY = 2026, AMO = 7, AD = 13;
function day(o){ if(!o) return null; return new Date(AY, AMO-1, AD + (o.day||0), o.hour||0, o.minute||0); }
const pad = n => String(n).padStart(2,"0");
function fmt(o){ const d = day(o); if(!d) return "—"; return `${d.getMonth()+1}/${d.getDate()} ${pad(d.getHours())}:${pad(d.getMinutes())}`; }
function rel(o){ if(!o) return ""; const n = -(o.day||0); return n<=0 ? "今日" : `${n}日前`; }

function L(key, fb){ return (DATA.labels && DATA.labels[key]) || fb || key; }

// ---- status ----
const STATUS_RAW = { explained:"explained", likelyExplained:"likely_explained",
  insufficientData:"insufficient_data", underReview:"under_review",
  notableUnresolved:"notable_unresolved", disputed:"disputed", withdrawn:"withdrawn" };
const STATUS_COLOR = { explained:"--s-explained", likelyExplained:"--s-likely",
  insufficientData:"--s-insufficient", underReview:"--s-review",
  notableUnresolved:"--s-review", disputed:"--s-disputed", withdrawn:"--s-corrected" };
// Each status has a distinct geometric signature (mirrors the app's
// StatusGeometry): status is carried by shape + colour + label, never colour
// alone. The same mark is used on badges, the observation visual, map pins,
// the legend and the timeline so a status is recognisable everywhere.
const STATUS_GEOM = {
  explained:"diamond", likelyExplained:"halfFilled", insufficientData:"openRingGap",
  underReview:"openRingTick", notableUnresolved:"pointInRing", disputed:"offsetArcs",
  withdrawn:"diamondRevision",
};
const STATUS_DIAMOND = { explained:1, withdrawn:1 };
function statusInfo(name){
  const raw = STATUS_RAW[name] || name;
  return { label: L("case.status."+raw, name),
           color: `var(${STATUS_COLOR[name]||"--s-review"})`,
           geom: STATUS_GEOM[name] || "openRingTick",
           diamond: !!STATUS_DIAMOND[name] };
}

// Inner SVG for a status geometry in a 24×24 box, stroked/filled with `c`.
function glyphInner(geom, c){
  switch(geom){
    case "diamond":
      return `<rect x="5.5" y="5.5" width="13" height="13" rx="1.6" transform="rotate(45 12 12)" fill="none" stroke="${c}" stroke-width="2"/>`;
    case "diamondRevision":
      return `<rect x="6" y="6" width="12" height="12" rx="1.4" transform="rotate(45 12 12)" fill="none" stroke="${c}" stroke-width="1.9"/><circle cx="18.5" cy="5.5" r="2.3" fill="${c}"/>`;
    case "halfFilled":
      return `<circle cx="12" cy="12" r="8" fill="none" stroke="${c}" stroke-width="1.8"/><path d="M12 4 A8 8 0 0 0 12 20 Z" fill="${c}"/>`;
    case "openRingGap":
      return `<path d="M12 4 A8 8 0 1 1 6.1 5.7" fill="none" stroke="${c}" stroke-width="1.8" stroke-linecap="round"/>`;
    case "openRingTick":
      return `<circle cx="12" cy="12" r="8" fill="none" stroke="${c}" stroke-width="1.8"/><line x1="12" y1="1.6" x2="12" y2="6" stroke="${c}" stroke-width="2" stroke-linecap="round"/>`;
    case "pointInRing":
      return `<circle cx="12" cy="12" r="8" fill="none" stroke="${c}" stroke-width="1.6"/><circle cx="12" cy="12" r="3.2" fill="${c}"/>`;
    case "offsetArcs":
      return `<path d="M4.5 9 A7.5 7.5 0 0 1 19.5 9" fill="none" stroke="${c}" stroke-width="1.9" stroke-linecap="round"/><path d="M4.5 15 A7.5 7.5 0 0 0 19.5 15" fill="none" stroke="${c}" stroke-width="1.9" stroke-linecap="round"/>`;
    case "squareOutline":
      return `<rect x="5" y="5" width="14" height="14" rx="2" fill="none" stroke="${c}" stroke-width="1.8"/>`;
    default:
      return `<circle cx="12" cy="12" r="7" fill="none" stroke="${c}" stroke-width="1.8"/>`;
  }
}
function statusGlyphSVG(name, size){
  const s = statusInfo(name);
  return `<svg class="sglyph" width="${size}" height="${size}" viewBox="0 0 24 24" aria-hidden="true">${glyphInner(s.geom, s.color)}</svg>`;
}
function badge(name){
  const s = statusInfo(name);
  return `<span class="badge" style="color:${s.color};border-color:${s.color}44;background:${s.color}14">${statusGlyphSVG(name,14)}${s.label}</span>`;
}

const CAT_RAW = { cameraArtifact:"camera_artifact" };
const catLabel = c => L("explanation.category."+(CAT_RAW[c]||c), c);
const SRC_RAW = { openData:"open_data" };
const srcLabel = t => L("source.type."+(SRC_RAW[t]||t), t);
const roleLabel = r => L("evidence.role."+r, r);
const ROLE_COLOR = { supports:"--s-explained", contradicts:"--s-disputed", contextualizes:"--textTertiary" };
function srcIcon(t){
  const p = {
    official:'<path d="M3 9l7-5 7 5M4 9v9M16 9v9M2 20h16M7 12v4M10 12v4M13 12v4" fill="none" stroke="currentColor" stroke-width="1.4"/>',
    press:'<rect x="3" y="4" width="14" height="13" rx="1.5" fill="none" stroke="currentColor" stroke-width="1.4"/><path d="M6 8h5M6 11h8M6 14h8" stroke="currentColor" stroke-width="1.3"/>',
    scientific:'<circle cx="10" cy="10" r="2" fill="currentColor"/><ellipse cx="10" cy="10" rx="8" ry="3.4" fill="none" stroke="currentColor" stroke-width="1.3"/><ellipse cx="10" cy="10" rx="8" ry="3.4" transform="rotate(60 10 10)" fill="none" stroke="currentColor" stroke-width="1.3"/>',
    database:'<ellipse cx="10" cy="5" rx="6" ry="2.4" fill="none" stroke="currentColor" stroke-width="1.4"/><path d="M4 5v10c0 1.3 2.7 2.4 6 2.4s6-1.1 6-2.4V5" fill="none" stroke="currentColor" stroke-width="1.4"/>',
    social:'<path d="M4 5h12v8H9l-4 3v-3H4z" fill="none" stroke="currentColor" stroke-width="1.4"/>',
    openData:'<path d="M4 4h5v5H4zM11 4h5v5h-5zM4 11h5v5H4zM11 11h5v5h-5z" fill="none" stroke="currentColor" stroke-width="1.3"/>',
  }[t] || '<circle cx="10" cy="10" r="7" fill="none" stroke="currentColor" stroke-width="1.4"/>';
  return `<svg class="sicon" width="15" height="15" viewBox="0 0 20 20" aria-hidden="true">${p}</svg>`;
}
const discLabel = d => L("ai.disclosure."+({autoGenerated:"ai_auto",editorReviewed:"ai_reviewed",humanWritten:"human"}[d]||d), d);

const AXES = [
  ["evidenceQuality","証拠品質","--axis-evidence"],
  ["independence","独立報告性","--axis-independence"],
  ["knownPhenomenaMatch","既知現象一致度","--axis-known"],
  ["unresolvedness","未解明度","--axis-unresolved"],
];

const esc = s => (s==null?"":String(s)).replace(/[&<>"]/g,c=>({"&":"&amp;","<":"&lt;",">":"&gt;",'"':"&quot;"}[c]));

// ---- DOM refs ----
const $screen = () => document.getElementById("screen");
const $nav = () => document.getElementById("nav");

function setState(patch){ Object.assign(state, patch); render(); }

// ================= screens =================
function heroToday(){
  const s = DATA.summary, b = DATA.briefing;
  const anchor = new Date(AY, AMO-1, AD);
  const dateStr = `${anchor.getFullYear()}年${anchor.getMonth()+1}月${anchor.getDate()}日`;
  const stat = (v,l)=>`<div class="stat"><b>${v}</b><span>${l}</span></div>`;
  return `<div class="hero"><div class="orb"></div>
    <div class="date">${dateStr} · 世界の空</div>
    <h2>${esc(b.headline)}</h2>
    <div class="stats">
      ${stat(s.newReportCount,"新規報告")}
      ${stat(s.mergedCaseCount,"統合事象")}
      ${stat(s.notableUnresolvedCount,"注目・未解明")}
      ${stat(s.likelyExplainedCount,"説明が進行")}
      ${stat(s.insufficientDataCount,"情報不足")}
      ${stat(b.sourceCount,"参照ソース")}
    </div></div>`;
}

function briefingCard(){
  const b = DATA.briefing;
  const free = `<p class="case-sum">${esc(b.summary)}</p>`;
  let body;
  if(state.plus){
    body = b.blocks.map(bl=>renderBlock(bl)).join("");
    body += `<div class="meta"><span>読了 約${b.readingMinutes}分</span><span class="dot"></span><span>${esc(discLabel(b.disclosure))}</span></div>`;
  } else {
    body = `<div class="lock"><h4>SkyTrace Plus</h4>
      <p>世界ブリーフィング全文・AI統合記事・高度な照合を解放</p>
      <button class="btn primary" onclick="openPaywall('briefing')">続きを読む（Plus）</button></div>`;
  }
  return `<div class="card flat"><div class="row"><b>今日の世界ブリーフィング</b><span class="spacer" style="flex:1"></span>
    <span class="badge round" style="color:var(--warm);border-color:#e2c17b55">${esc(discLabel(b.disclosure))}</span></div>
    ${free}${body}</div>`;
}

// Observation lead visual (image-free, rights-safe) tinted by status + seeded by
// the case, echoing the app's ObservationGlyph / CaseLeadVisual. If a case ever
// carries a rights-cleared image it is shown instead (media[].url).
function clearedImage(c){
  const m = (c.media||[]).find(x=>x && x.url && x.inline);
  return m ? m.url : null;
}
function obsVisual(c, size){
  const img = clearedImage(c);
  if(img) return `<img src="${esc(img)}" alt="" style="width:100%;height:100%;object-fit:cover">`;
  const col = statusInfo(c.status).color;
  const h = isqrt((c.id||"").length + (c.title||"").length + c.status.length);
  const n = Math.max(3, Math.min(9, (c.shapeTags||[]).length + 3));
  let dots = "";
  for(let i=0;i<n;i++){
    const a = h*6.28 + i*(6.28/n);
    const rr = 16 + (i%3)*8;
    const x = 50 + Math.cos(a)*rr, y = 52 + Math.sin(a)*rr*0.7;
    dots += `<circle cx="${x.toFixed(1)}" cy="${y.toFixed(1)}" r="${(1.1+(i%3)*0.5).toFixed(1)}" fill="${col}" opacity="${(0.5+ (i%4)/8).toFixed(2)}"/>`;
  }
  const focalScale = size==="F" ? 1.5 : 1.15;
  const tx = (50 - 12*focalScale).toFixed(2), ty = (42 - 12*focalScale).toFixed(2);
  const focal = `<g transform="translate(${tx},${ty}) scale(${focalScale})">${glyphInner(statusInfo(c.status).geom, col)}</g>`;
  const uid = (c.id||"") + size;
  return `<svg viewBox="0 0 100 84" preserveAspectRatio="xMidYMid slice" style="width:100%;height:100%">
    <defs><linearGradient id="g${uid}" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0" stop-color="#0b1621"/><stop offset="1" stop-color="#070b14"/></linearGradient>
      <radialGradient id="h${uid}" cx="50%" cy="42%" r="60%">
      <stop offset="0" stop-color="${col}" stop-opacity="0.30"/><stop offset="70%" stop-color="${col}" stop-opacity="0"/></radialGradient></defs>
    <rect width="100" height="84" fill="url(#g${uid})"/>
    <ellipse cx="50" cy="42" rx="46" ry="30" fill="url(#h${uid})"/>
    ${dots}${focal}</svg>`;
}

function caseCard(c, opts={}){
  if(opts.featured){
    return `<div class="card" onclick="openCase('${c.id}')">
      <div class="lead-lg">${obsVisual(c,"F")}</div>
      <div class="row">${badge(c.status)}<span style="flex:1"></span>
        <span class="st" style="color:var(--textTertiary);font-size:12px">${esc(rel(c.updatedAt))}</span></div>
      <div class="case-title">${esc(c.title)}</div>
      <p class="case-sum">${esc(clip(c.summary,110))}</p>
      <div class="meta"><span>${esc(regionLabel(c))}</span><span class="dot"></span>
        <span>出典 ${c.sourceCount}</span><span class="dot"></span><span>独立 ${c.independentReportCount}</span></div>
    </div>`;
  }
  return `<div class="card withthumb" onclick="openCase('${c.id}')">
    <div class="thumb">${obsVisual(c,"S")}</div>
    <div class="cbody">
      <div class="row">${badge(c.status)}<span style="flex:1"></span>
        <span class="st" style="color:var(--textTertiary);font-size:12px">${esc(rel(c.updatedAt))}</span></div>
      <div class="case-title" style="font-size:15px;margin:6px 0 3px">${esc(c.title)}</div>
      <div class="meta"><span>${esc(regionLabel(c))}</span><span class="dot"></span>
        <span>出典 ${c.sourceCount}</span><span class="dot"></span><span>独立 ${c.independentReportCount}</span></div>
    </div>
  </div>`;
}
const clip = (s,n)=> s && s.length>n ? s.slice(0,n)+"…" : (s||"");
function regionLabel(c){ return [c.localityName, c.regionName].filter(Boolean)[0] || c.countryCode || ""; }

function screenToday(){
  const top = DATA.topCaseIDs.map(id=>CASES[id]).filter(Boolean);
  const updates = DATA.cases.filter(c => c.timeline && c.timeline.some(t=>t.daysAgo<=1));
  const featured = top.length ? caseCard(top[0], {featured:true}) : "";
  const rest = top.slice(1).map(c=>caseCard(c)).join("");
  return heroToday() + briefingCard()
    + `<div class="section-title">今日の注目事例</div>`
    + `<div class="section-sub">観測の様子を表すビジュアル付き。権利許諾済みの画像がある事例はその画像を表示します。</div>`
    + featured + rest
    + `<div class="section-title">更新された事例</div>`
    + `<div class="section-sub">前回より評価や証拠が変わった事例です。</div>`
    + updates.map(c=>caseCard(c)).join("");
}

// ---- Map ----
function screenMap(){
  const W=358,H=200;
  const proj = c => ({ x:(c.longitude+180)/360*W, y:(90-c.latitude)/180*H });
  const filters = ["all","explained","likelyExplained","underReview","notableUnresolved","insufficientData","disputed","withdrawn"];
  const bar = filters.map(f=>{
    const lab = f==="all" ? "すべて" : statusInfo(f).label;
    return `<button class="fchip ${state.mapFilter===f?"active":""}" onclick="setMapFilter('${f}')">${lab}</button>`;
  }).join("");
  const shown = DATA.cases.filter(c => c.locationPrecision!=="withheld" && (state.mapFilter==="all"||c.status===state.mapFilter));
  // graticule
  let grat="";
  for(let lon=-150;lon<=150;lon+=30){ const x=(lon+180)/360*W; grat+=`<line x1="${x}" y1="0" x2="${x}" y2="${H}" stroke="#16283c" stroke-width="1"/>`; }
  for(let lat=-60;lat<=60;lat+=30){ const y=(90-lat)/180*H; grat+=`<line x1="0" y1="${y}" x2="${W}" y2="${y}" stroke="#16283c" stroke-width="1"/>`; }
  const eqY=(90-0)/180*H;
  const pins = shown.map(c=>{const p=proj(c);
    return `<div class="pin" style="left:${(p.x/W*100)}%;top:${(p.y/H*100)}%" title="${esc(c.title)}" onclick="openCase('${c.id}')">${statusGlyphSVG(c.status,16)}</div>`;}).join("");
  const list = shown.map(c=>caseCard(c)).join("") || `<div class="empty">この条件の事例はありません</div>`;
  const legendStatuses = ["explained","likelyExplained","underReview","notableUnresolved","insufficientData","disputed"];
  const legend = `<div class="legend">` + legendStatuses.map(s=>{
    const info = statusInfo(s);
    return `<span class="item">${statusGlyphSVG(s,15)}<span style="color:${info.color}">${info.label}</span></span>`;
  }).join("") + `</div>`;
  return `<div class="filterbar">${bar}</div>
    <div class="mapwrap"><svg viewBox="0 0 ${W} ${H}" preserveAspectRatio="none">
      <rect width="${W}" height="${H}" fill="url(#sky)"/>
      <defs><linearGradient id="sky" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#0b1621"/><stop offset="1" stop-color="#070d16"/></linearGradient></defs>
      ${grat}<line x1="0" y1="${eqY}" x2="${W}" y2="${eqY}" stroke="#22384f" stroke-width="1.5" stroke-dasharray="4 4"/>
    </svg>${pins}</div>
    <div class="meta" style="margin:2px 2px 6px"><span>世界地図（MapKitのプレビュー簡易表示）</span><span class="dot"></span><span>${shown.length}件</span></div>
    ${legend}
    <div class="section-sub">ピンの色と形は状態を表します。位置が公開できない事例は地図に表示されません。</div>
    ${list}`;
}

// ---- Research ----
function screenResearch(){
  const q = state.query.trim();
  let list = DATA.cases;
  if(q){ const lc=q.toLowerCase(); list = list.filter(c =>
    [c.title,c.summary,c.regionName,c.localityName,c.countryCode,(c.shapeTags||[]).join(" ")]
      .filter(Boolean).some(s=>s.toLowerCase().includes(lc))); }
  const body = list.length ? list.map(c=>caseCard(c)).join("") : `<div class="empty">「${esc(q)}」に一致する事例はありません</div>`;
  const tagset = [...new Set(DATA.cases.flatMap(c=>c.shapeTags||[]))].slice(0,10);
  const tags = tagset.map(t=>`<button class="fchip ${state.query===t?"active":""}" onclick="setQuery('${esc(t)}')">${esc(t)}</button>`).join("");
  return `<input class="search" placeholder="事例を検索（例：東京、光点、火球）" value="${esc(state.query)}" oninput="onSearch(this.value)">
    <div class="filterbar">${tags}</div>
    <div class="section-title">${q?`検索結果 ${list.length}件`:`すべての事例 ${DATA.cases.length}件`}</div>
    ${body}`;
}

// ---- Settings ----
function screenSettings(){
  const plusRow = `<div class="setrow" onclick="openPaywall('settings')">
    <div class="lab"><b>SkyTrace Plus</b><span>${state.plus?"購読中（デモ）":"世界ブリーフィング全文・AI統合記事"}</span></div>
    <span class="val">${state.plus?"管理":"詳細"}</span></div>`;
  const toggle = `<div class="setrow" onclick="togglePlus()">
    <div class="lab"><b>デモ用 entitlement 上書き</b><span>Plusコンテンツの表示を切り替え</span></div>
    <div class="toggle ${state.plus?"on":""}"><i></i></div></div>`;
  const link = (t,href,sub)=>`<div class="setrow" onclick="window.open('${href}','_blank')">
    <div class="lab"><b>${t}</b><span>${sub}</span></div><span class="val">↗</span></div>`;
  return `<div class="section-title">購読</div>${plusRow}
    <div class="setrow flat"><div class="lab"><b>購入を復元</b><span>以前の購読を復元</span></div><span class="val">復元</span></div>
    <div class="section-title">方針・法務（実在ページ）</div>
    ${link("プライバシーポリシー", LEGAL+"privacy/","端末内保存・トラッキングなし")}
    ${link("利用規約", LEGAL+"terms/","StoreKitによる購読")}
    ${link("編集方針", LEGAL+"editorial/","Case単位の統合")}
    ${link("AIの役割", LEGAL+"ai/","出典に紐づく生成")}
    ${link("4軸スコア", LEGAL+"scores/","スコアの意味")}
    ${link("サポート", LEGAL+"support/","問い合わせ")}
    <div class="section-title">デバッグ</div>${toggle}
    <div class="meta" style="justify-content:center;margin-top:18px"><span>SkyTrace preview · fixtures ${DATA.cases.length}件</span></div>`;
}

// ---- Case detail ----
function renderBlock(bl){
  if(bl.kind==="heading") return `<h3 style="font-size:14.5px;margin:14px 0 6px">${esc(bl.text)}</h3>`;
  if(bl.kind==="inference") return `<div class="li" style="border-left:3px solid var(--axis-independence)"><span class="chip" style="margin-bottom:6px;display:inline-block">推論${bl.confidence!=null?` · 確度${Math.round(bl.confidence*100)}%`:""}</span><div>${esc(bl.text)}</div></div>`;
  if(bl.kind==="unknown") return `<div class="li" style="border-left:3px solid var(--textTertiary)"><span class="chip" style="margin-bottom:6px;display:inline-block">未解明</span><div>${esc(bl.text)}</div></div>`;
  return `<p class="case-sum" style="margin:8px 0">${esc(bl.text)}</p>`;
}

function scoreGrid(sc){
  if(!sc) return "";
  return `<div class="scores">` + AXES.map(([k,l,c])=>{
    const v = sc[k];
    return `<div class="axis"><div class="k">${l}</div><div class="v">${v}</div>
      <div class="bar"><i style="width:${v}%;background:var(${c})"></i></div></div>`;
  }).join("") + `</div>`;
}

// A distinctive 4-axis "assessment compass": each axis fills its quadrant from
// the centre outward by its value. Quick to read, and unmistakably SkyTrace.
function scoreQuadrant(sc){
  if(!sc) return "";
  const C=88, MAX=64; // center, max reach
  const quad = [
    ["evidenceQuality", "--axis-evidence", -1, -1, "証拠品質"],
    ["independence",    "--axis-independence", 1, -1, "独立報告性"],
    ["knownPhenomenaMatch", "--axis-known", -1, 1, "既知現象一致度"],
    ["unresolvedness",  "--axis-unresolved", 1, 1, "未解明度"],
  ];
  let cells = "", labels = "";
  for(const [k,cvar,dx,dy,lab] of quad){
    const v = sc[k], reach = (v/100)*MAX;
    const x0 = dx<0 ? C-reach : C, y0 = dy<0 ? C-reach : C;
    const outX0 = dx<0 ? C-MAX : C, outY0 = dy<0 ? C-MAX : C;
    cells += `<rect x="${outX0}" y="${outY0}" width="${MAX}" height="${MAX}" fill="none" stroke="rgba(255,255,255,.06)"/>`;
    cells += `<rect x="${x0}" y="${y0}" width="${reach}" height="${reach}" fill="var(${cvar})" opacity="0.55" rx="2"/>`;
    const lx = dx<0 ? C-MAX+2 : C+MAX-2, ly = dy<0 ? C-MAX-6 : C+MAX+13;
    labels += `<text x="${lx}" y="${ly}" fill="var(${cvar})" font-size="9" text-anchor="${dx<0?"start":"end"}">${lab} ${v}</text>`;
  }
  return `<div class="quadrant"><svg viewBox="0 0 176 190" width="100%">
    ${cells}
    <line x1="${C-MAX}" y1="${C}" x2="${C+MAX}" y2="${C}" stroke="rgba(255,255,255,.14)"/>
    <line x1="${C}" y1="${C-MAX}" x2="${C}" y2="${C+MAX}" stroke="rgba(255,255,255,.14)"/>
    <circle cx="${C}" cy="${C}" r="2.4" fill="var(--accent)"/>
    ${labels}
  </svg></div>`;
}

function articleSection(c){
  const art = DATA.articles[c.id];
  if(!art) return "";
  let inner;
  if(state.plus){
    inner = `<div class="case-title" style="font-size:17px">${esc(art.headline)}</div>
      <p class="case-sum">${esc(art.dek)}</p>` + art.blocks.map(renderBlock).join("")
      + `<div class="meta"><span>版 v${art.versionNumber}</span><span class="dot"></span><span>読了 約${art.readingMinutes}分</span><span class="dot"></span><span>${esc(discLabel(art.disclosure))}</span></div>`
      + (art.correctionNote?`<div class="li" style="border-left:3px solid var(--warm)">訂正：${esc(art.correctionNote)}</div>`:"");
  } else {
    const teaser = art.blocks.find(b=>!b.gated);
    inner = `<div class="case-title" style="font-size:17px">${esc(art.headline)}</div>
      <p class="case-sum">${esc(art.dek)}</p>${teaser?renderBlock(teaser):""}
      <div class="lock"><h4>AI統合調査記事（Plus）</h4>
        <p>照合の詳細・推論・現時点の判断を、出典に紐づけて解説します。</p>
        <button class="btn primary" onclick="openPaywall('article')">記事を読む（Plus）</button></div>`;
  }
  return `<div class="d-sec"><h3>AI統合調査記事</h3><div class="card flat">${inner}</div></div>`;
}

function screenCase(){
  const c = CASES[state.caseID];
  if(!c) return `<div class="empty">事例が見つかりません</div>`;
  const glyph = `<div class="lead"><div class="g">${leadGlyph(c)}</div></div>`;
  const loc = [c.localityName,c.regionName].filter(Boolean).join("・");
  const times = `<div class="meta">
    <span>発生 ${fmt(c.occurredAtStart)}</span><span class="dot"></span>
    <span>公開 ${fmt(c.publishedAt)}</span><span class="dot"></span>
    <span>最終検証 ${fmt(c.lastVerifiedAt)}</span></div>`;
  const sec = (title,inner)=> inner ? `<div class="d-sec"><h3>${title}</h3>${inner}</div>` : "";
  const agree = c.agreements.map(t=>`<div class="li agree">${esc(t)}</div>`).join("");
  const contra = c.contradictions.map(t=>`<div class="li contra">${esc(t)}</div>`).join("");
  const cands = c.explanationCandidates.map(k=>`
    <div class="cand ${k.excluded?"excluded":""}">
      <div class="top"><span class="name">${esc(catLabel(k.category))}：${esc(k.label)}</span>
        <span class="tag">${k.excluded?"除外":`一致 ${k.matchScore}`}</span></div>
      <div class="matchbar"><i style="width:${k.excluded?0:k.matchScore}%"></i></div>
      <div class="chips">${k.match.map(m=>`<span class="chip">✓ ${esc(m)}</span>`).join("")}
        ${k.nonMatch.map(m=>`<span class="chip no">✗ ${esc(m)}</span>`).join("")}</div>
      ${k.limits?`<div class="st" style="margin-top:6px;color:var(--textTertiary);font-size:12px">データ制約：${esc(k.limits)}</div>`:""}
    </div>`).join("");
  const sources = c.sources.map(s=>`<div class="source" style="border-left:3px solid var(${ROLE_COLOR[s.role]||"--textTertiary"})">
      <span class="sicon-wrap" style="color:var(--accent2)">${srcIcon(s.type)}</span>
      <div style="flex:1;min-width:0"><b style="font-size:13.5px">${esc(s.outlet)}</b>
        <div class="st">${esc(s.title)}</div></div>
      <div style="text-align:right"><div class="st">${esc(srcLabel(s.type))}</div>
        <div class="st" style="color:var(${ROLE_COLOR[s.role]||"--textTertiary"})">${esc(roleLabel(s.role))}</div></div></div>`).join("");
  const tl = c.timeline.map(t=>`<div class="item">
      <div class="row" style="gap:8px">${t.status?badge(t.status):""}<span class="st" style="color:var(--textTertiary);font-size:12px">${esc(rel({day:-t.daysAgo}))}</span></div>
      <div style="margin-top:4px;font-size:13.5px">${esc(t.summary)}</div>
      ${t.scoreNote?`<div class="st" style="color:var(--warm);font-size:12px;margin-top:3px">${esc(t.scoreNote)}</div>`:""}
    </div>`).join("");
  const gaps = c.missingInformation.map(t=>`<div class="li">${esc(t)}</div>`).join("");

  return glyph
    + `<div class="row" style="margin-bottom:6px">${badge(c.status)}</div>`
    + `<div class="case-title" style="font-size:20px">${esc(c.title)}</div>`
    + `<div class="meta"><span>${esc(loc)}</span><span class="dot"></span><span>${esc(c.countryCode)}</span>
        <span class="dot"></span><span>精度：${esc(L("location.precision."+({exact:"exact",approximate:"approximate",regionOnly:"region_only",withheld:"withheld"}[c.locationPrecision]||c.locationPrecision), c.locationPrecision))}</span></div>`
    + times
    + `<div class="assess" style="margin-top:12px">${esc(c.summary)}</div>`
    + sec("4軸スコア", scoreQuadrant(c.scores) + scoreGrid(c.scores) + `<div class="st" style="color:var(--textTertiary);font-size:12px">未解明度が高いことは地球外起源を意味しません。単一の「信ぴょう性」ではなく4つの軸で示します。</div>`)
    + sec("複数情報で一致する点", agree)
    + sec("食い違う点", contra)
    + sec("既知現象との照合", cands)
    + sec("現時点の判断", `<div class="assess">${esc(c.currentAssessment)}</div>`)
    + articleSection(c)
    + sec("情報が不足している点", gaps)
    + sec("更新タイムライン", `<div class="tl">${tl}</div>`)
    + sec("出典", sources)
    + `<div class="meta" style="justify-content:center;margin:16px 0 6px"><span>すべてデモ事例（isDemo）です</span></div>`;
}

function leadGlyph(c){
  const col = statusInfo(c.status).color;
  return `<svg width="120" height="120" viewBox="0 0 120 120">
    <circle cx="60" cy="60" r="30" fill="none" stroke="${col}" stroke-opacity="0.9" stroke-width="1.5"/>
    <circle cx="60" cy="60" r="46" fill="none" stroke="${col}" stroke-opacity="0.35" stroke-width="1"/>
    <circle cx="60" cy="60" r="4" fill="${col}"/>
  </svg>`;
}

// ================= paywall =================
function paywallSheet(){
  return `<div class="sheet-scrim ${state.sheet?"show":""}" onclick="closePaywall()"></div>
  <div class="sheet ${state.sheet?"show":""}">
    <div class="grab"></div>
    <h2 style="margin:2px 0 4px;font-size:20px">SkyTrace Plus</h2>
    <p class="case-sum">毎日の世界ブリーフィング全文、事象別のAI統合調査記事、一致点・矛盾点・情報不足の可視化、詳細な既知現象照合。</p>
    <div class="plan best" onclick="subscribe()"><div class="p"><b>年額プラン</b><span>7日間の無料体験</span></div>
      <div class="price"><b>¥3,800 / 年</b><span>実質 ¥317 / 月</span></div></div>
    <div class="plan" onclick="subscribe()"><div class="p"><b>月額プラン</b><span>いつでも解約可能</span></div>
      <div class="price"><b>¥480 / 月</b><span>自動更新</span></div></div>
    <button class="btn primary block" style="margin-top:8px" onclick="subscribe()">無料体験を始める（デモ）</button>
    <button class="btn ghost block" style="margin-top:8px" onclick="closePaywall()">購入を復元</button>
    <div class="legal">自動更新サブスクリプション。期間終了の24時間前までに解約しない限り自動更新されます。<br>
      <a href="${LEGAL}terms/" target="_blank">利用規約</a> · <a href="${LEGAL}privacy/" target="_blank">プライバシー</a></div>
  </div>`;
}

// ================= actions =================
window.openCase = id => setState({ caseID:id });
window.closeCase = () => setState({ caseID:null });
window.setTab = t => setState({ tab:t, caseID:null });
window.setMapFilter = f => setState({ mapFilter:f });
window.setQuery = q => setState({ query:q });
window.onSearch = q => { state.query=q; renderScreenOnly(); };
window.togglePlus = () => setState({ plus:!state.plus });
window.openPaywall = () => setState({ sheet:true });
window.closePaywall = () => setState({ sheet:false });
window.subscribe = () => { state.plus=true; setState({ sheet:false }); };

// ================= render =================
const TABS = [
  ["today","tab.today","今日", '<path d="M12 3l7 6v10a1 1 0 0 1-1 1h-4v-6h-4v6H6a1 1 0 0 1-1-1V9z" fill="none" stroke="currentColor" stroke-width="1.8"/>'],
  ["map","tab.map","地図", '<path d="M9 4L3 6v14l6-2 6 2 6-2V4l-6 2-6-2z M9 4v14 M15 6v14" fill="none" stroke="currentColor" stroke-width="1.8"/>'],
  ["research","tab.research","探す", '<circle cx="11" cy="11" r="6" fill="none" stroke="currentColor" stroke-width="1.8"/><path d="M20 20l-4-4" stroke="currentColor" stroke-width="1.8"/>'],
  ["settings","tab.settings","設定", '<circle cx="12" cy="12" r="3.2" fill="none" stroke="currentColor" stroke-width="1.8"/><path d="M12 3v3 M12 18v3 M3 12h3 M18 12h3 M5.6 5.6l2.1 2.1 M16.3 16.3l2.1 2.1 M18.4 5.6l-2.1 2.1 M7.7 16.3l-2.1 2.1" stroke="currentColor" stroke-width="1.6"/>'],
];

function navBar(){
  const plusFlag = state.plus
    ? `<span class="plusflag">Plus</span>`
    : `<span class="plusflag free">Free</span>`;
  if(state.caseID){
    return `<button class="back" onclick="closeCase()">‹ 戻る</button><div class="spacer"></div>${plusFlag}`;
  }
  const titles = { today:"今日", map:"地図", research:"探す", settings:"設定" };
  return `<div class="title">${titles[state.tab]}</div><div class="spacer"></div>${plusFlag}`;
}

function screenHTML(){
  if(state.caseID) return screenCase();
  switch(state.tab){
    case "today": return screenToday();
    case "map": return screenMap();
    case "research": return screenResearch();
    case "settings": return screenSettings();
  }
}

function renderScreenOnly(){ $screen().innerHTML = screenHTML(); }

let _lastView = null;
function render(){
  $nav().innerHTML = navBar();
  const sc = $screen();
  sc.innerHTML = screenHTML();
  // Animate on a genuine view change (tab switch or open/close detail), not on
  // in-place updates like live search, and never when reduced motion is set.
  const view = state.caseID ? ("case:"+state.caseID) : ("tab:"+state.tab);
  const reduce = window.matchMedia && window.matchMedia("(prefers-reduced-motion: reduce)").matches;
  if(view !== _lastView && !reduce){
    sc.classList.remove("enter"); void sc.offsetWidth; sc.classList.add("enter");
  }
  _lastView = view;
  document.querySelectorAll(".tab").forEach(t=>t.classList.toggle("active", t.dataset.tab===state.tab && !state.caseID));
  document.getElementById("sheetHost").innerHTML = paywallSheet();
  if(!state.caseID) sc.scrollTop = 0;
}

function starfield(){
  const host = document.getElementById("cosmos");
  if(!host) return;
  const layer = (n, rmin, rmax, op) => {
    let dots = "";
    for(let i=0;i<n;i++){
      const x=(Math.sin(i*97.13)*0.5+0.5)*100, y=(Math.cos(i*57.31)*0.5+0.5)*100;
      const r=(rmin+((i*isqrt(i))%1)*(rmax-rmin)).toFixed(2);
      dots += `<circle cx="${x.toFixed(2)}%" cy="${y.toFixed(2)}%" r="${r}" fill="#CED8EC" opacity="${(op*(0.4+((i*13)%10)/16)).toFixed(2)}"/>`;
    }
    return `<svg class="stars" width="100%" height="100%" preserveAspectRatio="xMidYMid slice">${dots}</svg>`;
  };
  host.innerHTML = `<div class="aurora"></div>
    <div class="s1">${layer(46,0.5,1.2,0.9)}</div>
    <div class="s2">${layer(30,0.6,1.6,0.7)}</div>`;
}
function isqrt(i){ const s=Math.sin(i*12.9898)*43758.5453; return s-Math.floor(s); }

function hideSplash(){
  const el = document.getElementById("splash");
  if(!el) return;
  const reduce = window.matchMedia && window.matchMedia("(prefers-reduced-motion: reduce)").matches;
  setTimeout(()=>el.classList.add("hide"), reduce ? 600 : 1300);
}

function boot(data){
  DATA = data;
  DATA.cases.forEach(c=>CASES[c.id]=c);
  document.getElementById("tabbar").innerHTML = TABS.map(([id,,lab,svg])=>
    `<button class="tab" data-tab="${id}" onclick="setTab('${id}')"><svg viewBox="0 0 24 24">${svg}</svg>${L(TABS.find(t=>t[0]===id)[1],lab)}</button>`).join("");
  starfield();
  render();
  hideSplash();
}

fetch("data.json").then(r=>r.json()).then(boot).catch(e=>{
  document.getElementById("screen").innerHTML = `<div class="empty">データを読み込めませんでした：${esc(e.message)}<br>先に <code>python3 scripts/extract_fixtures.py</code> を実行してください。</div>`;
});
