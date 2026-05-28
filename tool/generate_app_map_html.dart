import 'dart:convert';
import 'dart:io';

void main() {
  final source = File('assets/maps/mudra_app_map.json');
  final target = File('docs/vibes/APP_MAP.html');
  final normalizedJson = const JsonEncoder.withIndent('  ')
      .convert(jsonDecode(source.readAsStringSync()));
  target.writeAsStringSync(_html.replaceFirst('__MAP_DATA__', normalizedJson));
  stdout.writeln('Generated ${target.path} from ${source.path}');
}

const _html = r'''<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Mudra — App Map</title>
<style>
  :root {
    --bg:#fff; --surface:#fff; --surface-alt:#f3f1ec; --border:#e6e2da;
    --ink:#1a1714; --ink-mid:#4a4642; --ink-dim:#8c8480;
    --gold:#8a6520; --green:#1e6b44; --red:#a83226; --amber:#9a5510; --blue:#1a5f8a;
    --connector:#d4cfca;
  }
  * { box-sizing:border-box; }
  body {
    margin:0;
    min-height:100vh;
    background:var(--bg);
    color:var(--ink);
    font-family:"IBM Plex Sans", Inter, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
  }
  .page-header {
    position:sticky; top:0; z-index:10;
    display:flex; align-items:center; justify-content:space-between; gap:16px;
    padding:14px 22px;
    background:rgba(255,255,255,.94);
    border-bottom:1px solid var(--border);
    backdrop-filter:blur(10px);
  }
  h1 {
    margin:0;
    font-family:"Cormorant Garamond", Georgia, serif;
    font-size:27px;
    font-weight:600;
    color:var(--gold);
  }
  .subtitle {
    margin-top:2px;
    font-family:"IBM Plex Mono", ui-monospace, monospace;
    font-size:10px;
    color:var(--ink-dim);
    letter-spacing:.08em;
    text-transform:uppercase;
  }
  .btn {
    border:1px solid var(--border);
    border-radius:8px;
    background:var(--surface);
    color:var(--gold);
    font:600 12px "IBM Plex Sans", sans-serif;
    padding:8px 12px;
    cursor:pointer;
  }
  .btn:hover { background:#f5edd9; border-color:var(--gold); }
  .board-wrap {
    width:100vw;
    height:calc(100vh - 65px);
    overflow:auto;
    cursor:grab;
  }
  .board {
    position:relative;
    min-width:100%;
    min-height:100%;
    background:
      linear-gradient(var(--border) 1px, transparent 1px),
      linear-gradient(90deg, var(--border) 1px, transparent 1px);
    background-size:48px 48px;
    background-position:-1px -1px;
  }
  svg.connectors {
    position:absolute;
    inset:0;
    overflow:visible;
    pointer-events:none;
  }
  .node {
    position:absolute;
    width:132px;
    min-height:64px;
    border:1.1px solid var(--border);
    border-radius:7px;
    background:var(--surface-alt);
    color:var(--ink);
    display:flex;
    align-items:center;
    justify-content:center;
    text-align:center;
    padding:7px 9px;
    box-shadow:0 3px 7px rgba(26,23,20,.05);
    user-select:none;
  }
  .node.has-children { cursor:pointer; }
  .node.has-children:hover { transform:translateY(-1px); box-shadow:0 6px 14px rgba(26,23,20,.09); }
  .node-inner { max-width:100%; }
  .label {
    display:flex;
    align-items:center;
    justify-content:center;
    gap:3px;
    font-size:10px;
    font-weight:600;
    line-height:1.1;
  }
  .sub {
    margin-top:3px;
    color:var(--ink-dim);
    font:8px/1.05 "IBM Plex Mono", ui-monospace, monospace;
  }
  .chevron { opacity:.75; font-size:11px; }
  .decision {
    width:92px;
    min-height:92px;
    border-width:1.8px;
    border-radius:13px;
    transform:rotate(45deg);
  }
  .decision .node-inner { transform:rotate(-45deg); }
  .decision .label { font-size:9px; }
  .c-shell { background:var(--gold); border-color:var(--gold); color:#fff; }
  .c-home { background:var(--ink); border-color:var(--ink); color:#fff; }
  .c-funds { background:var(--green); border-color:var(--green); color:#fff; }
  .c-debts { background:var(--red); border-color:var(--red); color:#fff; }
  .c-invest { background:var(--amber); border-color:var(--amber); color:#fff; }
  .c-net { background:var(--blue); border-color:var(--blue); color:#fff; }
  .c-profile { background:var(--ink-dim); border-color:var(--ink-dim); color:#fff; }
  .c-action { background:var(--surface); color:var(--ink-mid); font-style:italic; }
  .c-shell .sub,.c-home .sub,.c-funds .sub,.c-debts .sub,.c-invest .sub,.c-net .sub,.c-profile .sub { color:rgba(255,255,255,.84); }
  .legend {
    position:fixed;
    right:18px;
    bottom:18px;
    display:flex;
    gap:10px;
    flex-wrap:wrap;
    max-width:420px;
    padding:10px 12px;
    border:1px solid var(--border);
    border-radius:8px;
    background:rgba(255,255,255,.94);
    box-shadow:0 8px 24px rgba(26,23,20,.08);
    font-size:11px;
    color:var(--ink-mid);
  }
  .legend span { display:flex; align-items:center; gap:6px; }
  .dot { width:9px; height:9px; border-radius:50%; display:inline-block; }
</style>
</head>
<body>
<header class="page-header">
  <div>
    <h1>Mudra — App Map</h1>
    <div class="subtitle">Interactive flow board · click cards to expand</div>
  </div>
  <button class="btn" id="toggle-all">Expand all</button>
</header>
<main class="board-wrap" id="board-wrap">
  <div class="board" id="board">
    <svg class="connectors" id="connectors"></svg>
  </div>
</main>
<aside class="legend">
  <span><i class="dot" style="background:#8a6520"></i>Shell</span>
  <span><i class="dot" style="background:#1a1714"></i>Home</span>
  <span><i class="dot" style="background:#1e6b44"></i>Funds</span>
  <span><i class="dot" style="background:#a83226"></i>Debts</span>
  <span><i class="dot" style="background:#9a5510"></i>Invests</span>
  <span><i class="dot" style="background:#1a5f8a"></i>Net</span>
</aside>
<script>
const TREE = __MAP_DATA__;
const expanded = new Set();
const W = 132, H = 64, D = 92, COL = 32, ROW = 14, PAD = 18;

function hasChildren(node) { return node.children && node.children.length; }
function sizeFor(node) { return node.kind === 'decision' ? {w:D,h:D} : {w:W,h:H}; }
function expandableIds(node, ids = []) {
  if (hasChildren(node)) ids.push(node.id);
  (node.children || []).forEach(child => expandableIds(child, ids));
  return ids;
}
function layout(root) {
  const nodes = [], edges = [];
  function place(node, depth, top) {
    const visible = expanded.has(node.id) ? (node.children || []) : [];
    const size = sizeFor(node);
    const left = PAD + depth * (W + COL);
    if (!visible.length) {
      nodes.push({node, depth, x:left, y:top, w:size.w, h:size.h});
      return top + size.h + ROW;
    }
    let cursor = top;
    const childRects = [];
    visible.forEach(child => {
      const before = nodes.length;
      cursor = place(child, depth + 1, cursor);
      edges.push({parentId:node.id, childId:child.id});
      childRects.push(nodes[before]);
    });
    const t = Math.min(...childRects.map(r => r.y));
    const b = Math.max(...childRects.map(r => r.y + r.h));
    const y = Math.max(PAD, t + (b - t - size.h) / 2);
    nodes.push({node, depth, x:left, y, w:size.w, h:size.h});
    return Math.max(cursor, top + size.h + ROW);
  }
  const bottom = place(root, 0, PAD);
  const right = Math.max(...nodes.map(n => n.x + n.w));
  return {nodes, edges, width:right + PAD, height:Math.max(bottom + PAD, H + PAD * 2)};
}
function render() {
  const board = document.getElementById('board');
  const svg = document.getElementById('connectors');
  board.querySelectorAll('.node').forEach(el => el.remove());
  svg.innerHTML = '';
  const data = layout(TREE);
  board.style.width = Math.max(data.width, window.innerWidth) + 'px';
  board.style.height = Math.max(data.height, window.innerHeight - 65) + 'px';
  svg.setAttribute('width', board.style.width);
  svg.setAttribute('height', board.style.height);
  const byId = new Map(data.nodes.map(item => [item.node.id, item]));
  data.edges.forEach(edge => {
    const p = byId.get(edge.parentId), c = byId.get(edge.childId);
    const sx = p.x + p.w, sy = p.y + p.h / 2, ex = c.x, ey = c.y + c.h / 2;
    const mx = sx + Math.max(18, (ex - sx) * .52);
    const path = document.createElementNS('http://www.w3.org/2000/svg', 'path');
    path.setAttribute('d', `M ${sx} ${sy} C ${mx} ${sy}, ${mx} ${ey}, ${ex} ${ey}`);
    path.setAttribute('fill', 'none');
    path.setAttribute('stroke', '#d4cfca');
    path.setAttribute('stroke-width', '1.5');
    path.setAttribute('stroke-linecap', 'round');
    svg.appendChild(path);
    const arrow = document.createElementNS('http://www.w3.org/2000/svg', 'path');
    arrow.setAttribute('d', `M ${ex - 5} ${ey - 5} L ${ex} ${ey} L ${ex - 5} ${ey + 5}`);
    arrow.setAttribute('fill', 'none');
    arrow.setAttribute('stroke', '#d4cfca');
    arrow.setAttribute('stroke-width', '1.4');
    arrow.setAttribute('stroke-linecap', 'round');
    svg.appendChild(arrow);
  });
  data.nodes.forEach(item => {
    const el = document.createElement('div');
    el.className = `node c-${item.node.color || 'leaf'}${item.node.kind === 'decision' ? ' decision' : ''}${hasChildren(item.node) ? ' has-children' : ''}`;
    el.style.left = item.x + 'px';
    el.style.top = item.y + 'px';
    el.style.width = item.w + 'px';
    el.style.minHeight = item.h + 'px';
    el.innerHTML = `<div class="node-inner"><div class="label">${escapeHtml(item.node.label)}${hasChildren(item.node) ? `<span class="chevron">${expanded.has(item.node.id) ? '⌃' : '⌄'}</span>` : ''}</div>${item.node.sub ? `<div class="sub">${escapeHtml(item.node.sub)}</div>` : ''}</div>`;
    if (hasChildren(item.node)) el.addEventListener('click', () => {
      expanded.has(item.node.id) ? expanded.delete(item.node.id) : expanded.add(item.node.id);
      render();
    });
    board.appendChild(el);
  });
  const ids = expandableIds(TREE);
  const all = ids.length && ids.every(id => expanded.has(id));
  document.getElementById('toggle-all').textContent = all ? 'Collapse all' : 'Expand all';
}
function escapeHtml(value) {
  return String(value).replace(/[&<>"']/g, ch => ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[ch]));
}
document.getElementById('toggle-all').addEventListener('click', () => {
  const ids = expandableIds(TREE);
  const all = ids.length && ids.every(id => expanded.has(id));
  expanded.clear();
  if (!all) ids.forEach(id => expanded.add(id));
  render();
});
window.addEventListener('resize', render);
render();
</script>
</body>
</html>
''';
