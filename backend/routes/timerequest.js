const express = require("express");
const router = express.Router();
const prisma = require("../prismaClient");

// Apply/Submit time request (Employee)
router.post("/", async (req, res) => {
    const { employeeId, requestType, date, timeIn, timeOut, reason } = req.body;
    try {
        const timeReq = await prisma.time_requests.create({
            data: {
                employee_id: parseInt(employeeId),
                request_type: requestType,
                date: new Date(date),
                time_in: timeIn,
                time_out: timeOut,
                reason: reason,
                status: "Pending",
            },
        });
        res.status(201).json({ message: "Time request submitted successfully", timeReq });
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: "Server error" });
    }
});

// Fetch time requests for a specific employee
router.get("/employee/:id", async (req, res) => {
    const { id } = req.params;
    try {
        const requests = await prisma.time_requests.findMany({
            where: { employee_id: parseInt(id) },
            orderBy: { created_at: "desc" },
        });
        res.status(200).json(requests);
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: "Server error" });
    }
});

// Fetch all time requests for HR view
router.get("/all", async (req, res) => {
    try {
        const requests = await prisma.time_requests.findMany({
            orderBy: { created_at: "desc" },
            include: {
                employee: {
                    select: { first_name: true, last_name: true }
                }
            }
        });
        res.status(200).json(requests);
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: "Server error" });
    }
});

// Update time request status (Approve/Decline by HR)
router.put("/:id/status", async (req, res) => {
    const { id } = req.params;
    const { status } = req.body; // "Approved" or "Declined"

    try {
        // Update the request status
        const updatedRequest = await prisma.time_requests.update({
            where: { id: parseInt(id) },
            data: { status },
        });

        // If Approved, sync with the attendance table!
        if (status === "Approved") {
            const reqData = updatedRequest;
            const targetDate = reqData.date; // Note: Prisma Date string
            
            // Look up existing attendance for this date
            const existingAttendance = await prisma.attendance.findFirst({
                where: {
                    employee_id: reqData.employee_id,
                    date: targetDate,
                }
            });

            if (existingAttendance) {
                // Update existing record
                await prisma.attendance.update({
                    where: { id: existingAttendance.id },
                    data: {
                        punch_in_time: reqData.time_in ? reqData.time_in : existingAttendance.punch_in_time,
                        punch_out_time: reqData.time_out ? reqData.time_out : existingAttendance.punch_out_time,
                    }
                });
            } else {
                // Create a new record since none exists for this date
                await prisma.attendance.create({
                    data: {
                        employee_id: reqData.employee_id,
                        date: targetDate,
                        punch_in_time: reqData.time_in || null,
                        punch_out_time: reqData.time_out || null,
                        // Provide some manual override location string to prevent null issues
                        location: "HR Adjusted", 
                        location_name: "HR Adjusted"
                    }
                });
            }
        }

        res.status(200).json({ message: "Time request status updated", request: updatedRequest });
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: "Server error" });
    }
});

module.exports = router;
