const fs = require('fs');
const path = require('path');

function generateEnvJs() {
  const envPath = path.resolve(__dirname, '.env');
  const outputPath = path.resolve(__dirname, 'env.js');

  let envVars = {};

  if (fs.existsSync(envPath)) {
    const lines = fs.readFileSync(envPath, 'utf8').split('\n');
    lines.forEach(line => {
      const trimmed = line.trim();
      if (!trimmed || trimmed.startsWith('#')) return;
      const parts = trimmed.split('=');
      if (parts.length >= 2) {
        const key = parts[0].trim();
        let value = parts.slice(1).join('=').trim();
        if ((value.startsWith('"') && value.endsWith('"')) || (value.startsWith("'") && value.endsWith("'"))) {
          value = value.slice(1, -1);
        }
        envVars[key] = value;
      }
    });
  }

  // Only expose client-safe variables to the browser.
  // NEWS_API_KEY hanya dipakai saat localhost (live pakai berita mock), dan
  // LEGACY_ADMIN_PASSWORD tidak dibaca halaman mana pun — jangan dikirim ke browser.
  const clientEnv = {
    SUPABASE_URL: process.env.SUPABASE_URL || envVars.SUPABASE_URL || '',
    SUPABASE_ANON_KEY: process.env.SUPABASE_ANON_KEY || envVars.SUPABASE_ANON_KEY || '',
    EMAILJS_PUBLIC_KEY: process.env.EMAILJS_PUBLIC_KEY || envVars.EMAILJS_PUBLIC_KEY || ''
  };

  const fileContent = `// Auto-generated file. Do not edit directly or commit to version control.
window.ENV = ${JSON.stringify(clientEnv, null, 2)};
`;

  fs.writeFileSync(outputPath, fileContent, 'utf8');
  console.log('Successfully generated env.js with client-safe environment variables.');
}

generateEnvJs();
