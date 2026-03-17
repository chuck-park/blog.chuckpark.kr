const fs = require("fs");
const pkg = require("./package.json");
const filename = process.argv[2] || "assets/js/main.min.js";
const script = fs.readFileSync(filename);
const padStart = str => ("0" + str).slice(-2);
const dateObj = new Date();
const date = `${dateObj.getFullYear()}-${padStart(
  dateObj.getMonth() + 1
)}-${padStart(dateObj.getDate())}`;
const themeName = filename.includes("inkframe") ? "Inkframe" : "Minimal Mistakes Jekyll Theme";
const banner = `/*!
 * ${themeName} ${pkg.version} by ${pkg.author}
 * Copyright 2013-${dateObj.getFullYear()} Michael Rose - mademistakes.com | @mmistakes
 * Licensed under ${pkg.license}
 */
`;

if (script.slice(0, 3) != "/**") {
  fs.writeFileSync(filename, banner + script);
}
