const prisma = require('./prismaClient');
const { checkLocation } = require('./geo');

const CENTER_LAT = 27.7172;
const CENTER_LON = 85.3240;
const RADIUS_KM = 0.5; // 500 meters

async function checkLatestAttendance() {
    try {
        console.log('Fetching latest attendance record...');
        const attendance = await prisma.attendance.findFirst({
            orderBy: { created_at: 'desc' },
            include: { employee: true }
        });

        if (!attendance) {
            console.log('No attendance records found.');
            return;
        }

        console.log(`Analyzing attendance for: ${attendance.employee.first_name} ${attendance.employee.last_name}`);
        console.log(`Punch Location: ${attendance.location}`);

        if (!attendance.location) {
            console.log('Attendance record missing location data.');
            return;
        }

        //parse location string lat, lon
        const [latStr, lonStr] = attendance.location.split(',');
        const userLat = parseFloat(latStr.trim());
        const userLon = parseFloat(lonStr.trim());

        if (isNaN(userLat) || isNaN(userLon)) {
            console.error('Invalid location format in database.');
            return;
        }

        const result = checkLocation(userLat, userLon, CENTER_LAT, CENTER_LON, RADIUS_KM);

        console.log('-----------------------------------------');
        console.log(`Distance from office: ${result.distance} km`);
        if (result.isInside) {
            console.log('\x1b[32m%s\x1b[0m', 'Status: INSIDE allowed radius. ✅');
        } else {
            console.log('\x1b[31m%s\x1b[0m', 'Status: OUTSIDE allowed radius. ❌');
            console.log(`Extra distance: ${result.extraDistance} km`);
        }
        console.log('-----------------------------------------');

    } catch (error) {
        console.error('Error checking attendance:', error);
    } finally {
        await prisma.$disconnect();
    }
}

checkLatestAttendance();
