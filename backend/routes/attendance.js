const express = require('express');
const router = express.Router();
const prisma = require('../prismaClient');
const { checkLocation } = require('../geo');

//configurationn (herald clz)
const CENTER_LAT = 27.712094;
const CENTER_LON = 85.3307661;
const RADIUS_KM = 0.5;

router.post('/punch-in', async (req, res) => {
    const { employeeId, location, date, time } = req.body;

    if (!employeeId || !date || !time) {
        return res.status(400).json({ message: 'Missing required fields' });
    }

    try {
        //Calculate proximity
        let locationResult = { distance: null, isInside: null };
        let locationName = "Unknown";

        if (location) {
            const [latStr, lonStr] = location.split(',');
            const userLat = parseFloat(latStr.trim());
            const userLon = parseFloat(lonStr.trim());
            if (!isNaN(userLat) && !isNaN(userLon)) {
                locationResult = checkLocation(userLat, userLon, CENTER_LAT, CENTER_LON, RADIUS_KM);

                const { getLocationName } = require('../geo');
                locationName = await getLocationName(userLat, userLon);
            }
        }

        const attendance = await prisma.attendance.create({
            data: {
                employee_id: employeeId,
                date: new Date(date),
                time: time,
                location: location,
                location_name: locationName,
                distance: locationResult.distance,
            },
        });

        res.status(201).json({
            message: locationResult.isInside
                ? `Punch in successful at ${locationName} (In Range)`
                : `Punch in successful at ${locationName} (Out of Range)`,
            attendance: attendance,
            proximity: locationResult
        });
    } catch (error) {
        console.error('Punch in error:', error);
        res.status(500).json({ message: 'Server error during punch in' });
    }
});

module.exports = router;
