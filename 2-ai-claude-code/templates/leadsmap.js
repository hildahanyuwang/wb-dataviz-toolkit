/* Static SVG map builders for the infographics. Requires landpaths.js first. */
(function () {
  var ELEC = "#009FDA", NAVY = "#002244", MID = "#006C99", GOLD = "#FDB714";

  // ---- nodes in the Africa-Asia crop (viewBox 1000x540), matches the React map ----
  var CNODES = [
    { id: "cpt", city: "Cape Town", sub: "$12.8B", x: 248, y: 506, r: 26, fin: true },
    { id: "lom", city: "Lomé", sub: "$5.3B", x: 150, y: 278, r: 16, fin: true },
    { id: "del", city: "New Delhi", sub: "$9.7B", x: 584, y: 150, r: 22, fin: true },
    { id: "tok", city: "Tokyo", sub: "2026", x: 941, y: 110, r: 12, fin: false },
  ];
  function arc(a, b) {
    var mx = (a.x + b.x) / 2, my = (a.y + b.y) / 2;
    var d = Math.hypot(b.x - a.x, b.y - a.y), cy = my - d * 0.28 - 28;
    return "M " + a.x + " " + a.y + " Q " + mx + " " + cy + " " + b.x + " " + b.y;
  }

  // Dark LEADS route map (for the flagship infographic)
  window.leadsCropMap = function () {
    var s = '<svg viewBox="0 0 1000 540" width="100%" xmlns="http://www.w3.org/2000/svg">';
    s += '<rect width="1000" height="540" fill="' + NAVY + '"/>';
    (window.LAND_PATHS_CROP || []).forEach(function (d) {
      s += '<path d="' + d + '" fill="#0A3656" stroke="#3E8BB8" stroke-opacity="0.45" stroke-width="0.7"/>';
    });
    // faint graticule
    [200, 371, 543, 714, 886].forEach(function (x) { s += '<line x1="' + x + '" y1="0" x2="' + x + '" y2="540" stroke="#fff" stroke-opacity="0.05"/>'; });
    [85, 199, 313, 426].forEach(function (y, i) { s += '<line x1="0" y1="' + y + '" x2="1000" y2="' + y + '" stroke="#fff" stroke-opacity="' + (i === 2 ? 0.12 : 0.05) + '"/>'; });
    var order = ["cpt", "lom", "del", "tok"], by = function (id) { return CNODES.filter(function (n) { return n.id === id; })[0]; };
    for (var i = 0; i < 3; i++) s += '<path d="' + arc(by(order[i]), by(order[i + 1])) + '" fill="none" stroke="' + ELEC + '" stroke-width="2.5" stroke-linecap="round"/>';
    CNODES.forEach(function (n) {
      s += '<circle cx="' + n.x + '" cy="' + n.y + '" r="' + n.r + '" fill="' + (n.fin ? ELEC : "none") + '" stroke="#fff" stroke-width="' + (n.fin ? 0 : 2) + '"/>';
      s += '<circle cx="' + n.x + '" cy="' + n.y + '" r="' + Math.max(3, n.r * 0.34) + '" fill="#fff"/>';
      s += '<text x="' + n.x + '" y="' + (n.y - n.r - 11) + '" text-anchor="middle" fill="#fff" font-size="19" font-weight="700">' + n.city + '</text>';
      s += '<text x="' + n.x + '" y="' + (n.y - n.r - 31) + '" text-anchor="middle" fill="#7FC9EC" font-size="14" font-weight="700">' + n.sub + '</text>';
    });
    s += '<text x="22" y="34" fill="#7FC9EC" font-size="13" font-weight="700" letter-spacing="0.14em">LEADS · 2024 → 2026</text>';
    s += "</svg>";
    return s;
  };

  // ---- light world footprint map (for the report sheet) ----
  var WNODES = [
    { city: "Cape Town", x: 551, y: 328 }, { city: "Lomé", x: 503, y: 216 },
    { city: "New Delhi", x: 715, y: 154 }, { city: "Tokyo", x: 888, y: 134 },
  ];
  window.worldReachMap = function () {
    var s = '<svg viewBox="0 0 1000 389" width="100%" xmlns="http://www.w3.org/2000/svg">';
    (window.LAND_PATHS_WORLD || []).forEach(function (d) {
      s += '<path d="' + d + '" fill="#E3EBF0" stroke="#C6D4DD" stroke-width="0.6"/>';
    });
    WNODES.forEach(function (n) {
      s += '<circle cx="' + n.x + '" cy="' + n.y + '" r="11" fill="' + ELEC + '" fill-opacity="0.18"/>';
      s += '<circle cx="' + n.x + '" cy="' + n.y + '" r="5" fill="' + ELEC + '"/>';
      s += '<text x="' + n.x + '" y="' + (n.y - 14) + '" text-anchor="middle" fill="' + NAVY + '" font-size="13" font-weight="700">' + n.city + '</text>';
    });
    s += "</svg>";
    return s;
  };
})();
