// Génère les SVG de l'icône « plan technique » (détaillée et simplifiée) + pages HTML de rendu.
const fs = require('fs'), path = require('path');
const D = __dirname;

function svg(detail) {
  const W = '#ffffff', B = '#9cc3f5', BG1 = '#1660ad', BG2 = '#0a2f62';
  let grid = '';
  if (detail) {
    for (let v = 32; v < 256; v += 24) grid += `M${v} 8V248M8 ${v}H248`;
  }
  const sw = detail ? 1 : 1.6; // épaisseurs relatives plus fortes en petite taille
  let inner = '';
  if (detail) {
    // rangée 1 : 4 disjoncteurs + différentiel
    for (const x of [88, 104, 120, 136]) inner += `<rect x="${x}" y="78" width="13" height="34" rx="2" fill="#0f4486" stroke="${W}" stroke-width="4"/><rect x="${x + 4}" y="90" width="5" height="9" fill="${W}"/>`;
    inner += `<rect x="152" y="78" width="18" height="34" rx="2" fill="#0f4486" stroke="${W}" stroke-width="4"/>`;
    // rangée 2 : contacteurs, alim (voyant ambre)
    inner += `<rect x="88" y="134" width="20" height="36" rx="2" fill="#0f4486" stroke="${W}" stroke-width="4"/><circle cx="98" cy="152" r="4" fill="none" stroke="${W}" stroke-width="3"/>`;
    inner += `<rect x="114" y="134" width="20" height="36" rx="2" fill="#0f4486" stroke="${W}" stroke-width="4"/><circle cx="124" cy="152" r="4" fill="none" stroke="${W}" stroke-width="3"/>`;
    inner += `<rect x="140" y="130" width="30" height="42" rx="2" fill="#0f4486" stroke="${W}" stroke-width="4"/><circle cx="155" cy="142" r="6" fill="#ffd166"/>`;
    // bornier
    for (let i = 0; i < 9; i++) inner += `<rect x="${88 + i * 9.4}" y="186" width="6" height="14" rx="1" fill="${W}"/>`;
    inner = `<path d="M82 95H174M82 152H174" stroke="${B}" stroke-width="5"/>` + inner;
  } else {
    inner = `<rect x="90" y="74" width="76" height="40" rx="3" fill="${W}"/>
      <rect x="90" y="132" width="44" height="40" rx="3" fill="${W}"/>
      <circle cx="154" cy="152" r="14" fill="#ffd166"/>
      <rect x="90" y="186" width="76" height="12" rx="2" fill="${B}"/>`;
  }
  return `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 256 256" width="256" height="256">
<defs><linearGradient id="bg" x1="0" y1="0" x2="1" y2="1"><stop offset="0" stop-color="${BG1}"/><stop offset="1" stop-color="${BG2}"/></linearGradient>
<clipPath id="cl"><rect x="8" y="8" width="240" height="240" rx="${detail ? 44 : 40}"/></clipPath></defs>
<rect x="8" y="8" width="240" height="240" rx="${detail ? 44 : 40}" fill="url(#bg)"/>
${detail ? `<path clip-path="url(#cl)" d="${grid}" stroke="#3a74b8" stroke-width="1.5" opacity=".7"/>` : ''}
<polygon points="76,52 ${detail ? 46 : 40},${detail ? 66 : 70} ${detail ? 46 : 40},${detail ? 194 : 190} 76,208" fill="#1a68b8" stroke="${W}" stroke-width="${7 * sw}" stroke-linejoin="round"/>
<polygon points="180,52 ${detail ? 210 : 216},${detail ? 66 : 70} ${detail ? 210 : 216},${detail ? 194 : 190} 180,208" fill="#1a68b8" stroke="${W}" stroke-width="${7 * sw}" stroke-linejoin="round"/>
<rect x="76" y="52" width="104" height="156" fill="#0f4486" stroke="${W}" stroke-width="${9 * sw}" stroke-linejoin="round"/>
${inner}
</svg>`;
}

fs.writeFileSync(path.join(D, 'icon-detail.svg'), svg(true));
fs.writeFileSync(path.join(D, 'icon-simple.svg'), svg(false));
const sizes = [16, 24, 32, 48, 64, 128, 256];
for (const s of sizes) {
  const f = s <= 32 ? 'icon-simple.svg' : 'icon-detail.svg';
  fs.writeFileSync(path.join(D, `r${s}.html`),
    `<!doctype html><html><body style="margin:0;background:transparent"><img src="${f}" width="${s}" height="${s}" style="display:block"></body></html>`);
}
console.log('ok');
