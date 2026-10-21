const fs = require('fs');
const path = require('path');

const rootDir = __dirname;
const VERSION = String.raw`\d+\.\d+\.\d+`;
const cssPattern = new RegExp(`href="style\\.css\\?v=(${VERSION})"`);
const jsPattern = new RegExp(`src="app\\.js\\?v=(${VERSION})"`);
const brokenPattern = /(?:href|src)="\.[^"]*"/g;

const htmlFiles = fs.readdirSync(rootDir).filter((name) => name.endsWith('.html')).sort();

if (htmlFiles.length === 0) {
    console.error('Gagal: tidak ada file *.html di root proyek.');
    process.exit(1);
}

const problems = [];
const versionMap = new Map();

for (const file of htmlFiles) {
    const content = fs.readFileSync(path.join(rootDir, file), 'utf8');
    const fileProblems = [];

    const cssMatch = content.match(cssPattern);
    const jsMatch = content.match(jsPattern);

    if (!cssMatch) {
        fileProblems.push('link style.css?v=X.Y.Z tidak ditemukan atau format versinya salah');
    }
    if (!jsMatch) {
        fileProblems.push('script app.js?v=X.Y.Z tidak ditemukan atau format versinya salah');
    }

    const broken = content.match(brokenPattern);
    if (broken) {
        fileProblems.push(`link rusak gaya insiden ".0.70": ${broken.join(', ')}`);
    }

    if (cssMatch) versionMap.set(`${file} (css)`, cssMatch[1]);
    if (jsMatch) versionMap.set(`${file} (js)`, jsMatch[1]);

    if (fileProblems.length > 0) {
        problems.push({ file, details: fileProblems });
    }
}

const versions = [...new Set(versionMap.values())];
if (versions.length > 1) {
    const detail = [...versionMap.entries()].map(([key, ver]) => `${key}: v${ver}`).join('\n  ');
    problems.push({
        file: '(konsistensi antar halaman)',
        details: [`versi cache-bust beda-beda:\n  ${detail}`]
    });
}

if (problems.length > 0) {
    console.error('CHECK ASSETS GAGAL:\n');
    for (const { file, details } of problems) {
        console.error(`X ${file}`);
        for (const d of details) console.error(`   - ${d}`);
        console.error('');
    }
    console.error('Perbaiki link style.css/app.js di file di atas, lalu jalankan lagi: npm run check:assets');
    process.exit(1);
}

console.log(`OK: ${htmlFiles.length} halaman lolos — style.css?v=${versions[0]} dan app.js?v=${versions[0]} konsisten di semua halaman.`);
