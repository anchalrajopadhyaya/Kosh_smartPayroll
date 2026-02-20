const { checkLocation } = require('../geo');

// Kathmandu coordinates for the center
const CENTER_LAT = 27.7172;
const CENTER_LON = 85.3240;
const RADIUS_KM = 0.5; // 500 meters

// Example user coordinates
const userCoords = [
    { lat: 27.7180, lon: 85.3250 },
    { lat: 27.7300, lon: 85.3400 } 
];

console.log(`Center Office: ${CENTER_LAT}, ${CENTER_LON}`);
console.log('-----------------------------------------');

userCoords.forEach((coord, index) => {
    const res = checkLocation(coord.lat, coord.lon, CENTER_LAT, CENTER_LON, RADIUS_KM);
    const status = res.isInside ? 'INSIDE' : 'OUTSIDE';
    const color = res.isInside ? '\x1b[32m' : '\x1b[31m';
    const reset = '\x1b[0m';

    console.log(`User ${index + 1} Location: ${coord.lat}, ${coord.lon}`);
    console.log(`Distance: ${res.distance} km`);
    console.log(`${color}Status: ${status}${reset}`);
    if (!res.isInside) {
        console.log(`Extra Distance: ${res.extraDistance} km`);
    }
    console.log('-----------------------------------------');
});
