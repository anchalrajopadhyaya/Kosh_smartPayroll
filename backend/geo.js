/*
Calculates the Haversine distance between two points in kilometers.
lat1 - Latitude of point 1
lon1 - Longitude of point 1
lat2 - Latitude of point 2
lon2- Longitude of point 2
and it returns Distance in kilometers
*/
function calculateHaversineDistance(lat1, lon1, lat2, lon2) {
  const R = 6371; // Earth's radius in kilometers
  const dLat = (lat2 - lat1) * (Math.PI / 180);
  const dLon = (lon2 - lon1) * (Math.PI / 180);
  const a =
    Math.sin(dLat / 2) * Math.sin(dLat / 2) +
    Math.cos(lat1 * (Math.PI / 180)) *
      Math.cos(lat2 * (Math.PI / 180)) *
      Math.sin(dLon / 2) *
      Math.sin(dLon / 2);
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
  return R * c;
}

/*
 Checks if a user is within a certain radius of a center location.
 returns distance, isInside, extraDistance
 */
function checkLocation(userLat, userLon, centerLat, centerLon, radiusKm = 0.5) {
  const distance = calculateHaversineDistance(userLat, userLon, centerLat, centerLon);
  const isInside = distance <= radiusKm;
  const extraDistance = isInside ? 0 : distance - radiusKm;

  return {
    distance: parseFloat(distance.toFixed(4)),
    isInside,
    extraDistance: parseFloat(extraDistance.toFixed(4))
  };
}

//get address name
async function getLocationName(lat, lon) {
    try {
        const response = await fetch(
            `https://nominatim.openstreetmap.org/reverse?format=json&lat=${lat}&lon=${lon}`,
            {
                headers: { 'User-Agent': 'KoshPayrollApp/1.0' }
            }
        );
        const data = await response.json();
        return data.display_name || "Unknown Location";
    } catch (error) {
        console.error("Geocoding error:", error);
        return "Unknown Location";
    }
}

module.exports = {
  calculateHaversineDistance,
  checkLocation,
  getLocationName
};
