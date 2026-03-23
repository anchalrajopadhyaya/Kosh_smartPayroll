const express = require('express');
const router = express.Router();
const prisma = require('../prismaClient');
const { checkLocation } = require('../geo');

//configurationn (herald clz)
const CENTER_LAT = 27.712094;
const CENTER_LON = 85.3307661;
const RADIUS_KM = 0.5; //500m

router.post('/punch-in', async (req, res) => {
    const { employeeId, location, date, time } = req.body;

    if (!employeeId || !date || !time) {
        return res.status(400).json({ message: 'Missing required fields' });
    }

    try {
        // Creating a date range covering the entire day (00:00 to 23:59)
        const targetDate = new Date(date);
        const startOfDay = new Date(targetDate.setUTCHours(0, 0, 0, 0));
        const endOfDay = new Date(targetDate.setUTCHours(23, 59, 59, 999));

        //employee punch in once a day
        const existingAttendance = await prisma.attendance.findFirst({
            where: {
                employee_id: employeeId,
                date: {
                    gte: startOfDay,
                    lte: endOfDay
                }
            }
        });

        if (existingAttendance) {
            return res.status(400).json({ message: 'You have already punched in today!' });
        }

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
                punch_in_time: time,
                punch_in_location: location,
                punch_in_location_name: locationName,
                punch_in_distance: locationResult.distance,
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

router.post('/punch-out', async (req, res) => {
    const { employeeId, location, date, time } = req.body;
    if (!employeeId || !date || !time) {
        return res.status(400).json({ message: 'Missing required fields' });
    }

    try {
        //finding latest attendance for this employee
        const latestAttendance = await prisma.attendance.findFirst({
            where: {
                employee_id: employeeId,
                date: new Date(date),
                punch_out_time: null
            },
            orderBy: { date: 'desc' },
        });

        if (!latestAttendance) {
            return res.status(404).json({ message: "no active punch in found for today" });
        }

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

        //Update the record
        const updateAttendance = await prisma.attendance.update({
            where: { id: latestAttendance.id },
            data: {
                punch_out_time: time,
                punch_out_location: location,
                punch_out_location_name: locationName,
                punch_out_distance: locationResult.distance,
            },
        });
        res.status(200).json({
            message: locationResult.isInside
                ? `Punch out successful at ${locationName} (In Range)` :
                `Punch out successful at ${locationName} (Out of Range)`,
            attendance: updateAttendance,
            proximity: locationResult
        });
    } catch (error) {
        console.error('Punch out error:', error);
        res.status(500).json({ message: 'Server error during punch out' });
    }
});

//Get today's attendance 
router.get('/status/:employeeId', async (req, res) => {
    const { employeeId } = req.params;
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    try {
        const attendance = await prisma.attendance.findFirst({
            where: {
                employee_id: parseInt(employeeId),
                date: today,
            },
            orderBy: { punch_in_time: 'desc' },
        });
        if (!attendance) {
            return res.status(200).json({ status: 'Punched_Out', attendance: null });
        }

        if (attendance.punch_out_time) {
            return res.status(200).json({ status: 'Punched_Out', attendance: attendance });
        }
        return res.status(200).json({ status: 'Punched_In', attendance: attendance });
    } catch (error) {
        console.error('Fetch status error:', error);
        res.status(500).json({ message: 'Server error fetching attendance status' });
    }
});


//Get Attendance History
router.get('/history/:employeeId', async (req, res) => {
    const { employeeId } = req.params;

    try {
        const history = await prisma.attendance.findMany({
            where: { employee_id: parseInt(employeeId) },
            orderBy: { date: 'desc' },
        });

        res.status(200).json(history);
    } catch (error) {
        console.error('Fetch history error:', error);
        res.status(500).json({ message: 'Server error fetching attendance history' });
    }
});

//Get Daily Attendance Report
router.get('/daily', async (req, res) => {
    const { date } = req.query; // YYYY-MM-DD
    if (!date) return res.status(400).json({ message: 'Date is required' });

    try {
        const queryDate = new Date(date);
        queryDate.setHours(0, 0, 0, 0);

        // 1. Get all employees
        const employees = await prisma.employees.findMany({
            select: {
                id: true,
                first_name: true,
                last_name: true,
                job_title: true,
                department: true,
            },
            orderBy: { first_name: 'asc' }
        });

        //getting attendance logs for that specific date
        const attendanceLogs = await prisma.attendance.findMany({
            where: { date: queryDate }
        });

        const report = employees.map(emp => {
            const log = attendanceLogs.find(log => log.employee_id === emp.id);
            return {
                id: emp.id,
                first_name: emp.first_name,
                last_name: emp.last_name,
                job_title: emp.job_title,
                department: emp.department,
                status: log ? (log.punch_out_time ? 'Present' : 'Logged In') : 'Absent',
                punch_in_time: log ? log.punch_in_time : null,
                punch_out_time: log ? log.punch_out_time : null,
                attendance_id: log ? log.id : null,
                //full log data for the detail dialog
                logData: log || null
            };
        });

        res.status(200).json(report);
    } catch (error) {
        console.error('Daily report error:', error);
        res.status(500).json({ message: 'Server error generating daily report' });
    }
});

module.exports = router;
