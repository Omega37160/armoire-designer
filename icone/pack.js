// Assemble des PNG (16..256) en un fichier .ico (entrées PNG, Windows Vista+).
const fs = require('fs'), path = require('path');
const [out, ...pngs] = process.argv.slice(2);
const imgs = pngs.map(p => {
  const b = fs.readFileSync(p);
  if (b.readUInt32BE(0) !== 0x89504e47) throw p + ' n\'est pas un PNG';
  return { b, w: b.readUInt32BE(16), h: b.readUInt32BE(20) };
});
const head = Buffer.alloc(6 + 16 * imgs.length);
head.writeUInt16LE(0, 0); head.writeUInt16LE(1, 2); head.writeUInt16LE(imgs.length, 4);
let off = head.length;
imgs.forEach((m, i) => {
  const e = 6 + i * 16;
  head.writeUInt8(m.w >= 256 ? 0 : m.w, e); head.writeUInt8(m.h >= 256 ? 0 : m.h, e + 1);
  head.writeUInt8(0, e + 2); head.writeUInt8(0, e + 3);
  head.writeUInt16LE(1, e + 4); head.writeUInt16LE(32, e + 6);
  head.writeUInt32LE(m.b.length, e + 8); head.writeUInt32LE(off, e + 12);
  off += m.b.length;
});
fs.writeFileSync(out, Buffer.concat([head, ...imgs.map(m => m.b)]));
console.log(out, imgs.map(m => m.w).join(','), off, 'octets');
