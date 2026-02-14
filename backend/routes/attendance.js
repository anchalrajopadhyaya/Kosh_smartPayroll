const express = require('express');
const router = express.Router();
const prisma = require('../prismaClient');

// Punch In
router.post('/punch-in', async (req, res) => {
    const { employeeId, location, date, time } = req.body;

    if (!employeeId || !date || !time) {
        return res.status(400).json({ message: 'Missing required fields' });
    }

    try {
        const attendance = await prisma.attendance.create({
            data: {
                employee_id: employeeId,
                date: new Date(date), // Expecting YYYY-MM-DD format or ISO string
                time: time,
                location: location,
            },
        });

        res.status(201).json({
            message: 'Punch in successful',
            attendance: attendance,
        });
    } catch (error) {
        console.error('Punch in error:', error);
        res.status(500).json({ message: 'Server error during punch in' });
    }
});

module.exports = router;
