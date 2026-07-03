const express = require("express");
const router = express.Router();
const prisma = require("../prismaClient");

// 1. Submit legal info update request (Employee)
router.post("/", async (req, res) => {
    const { employeeId, phone, pan, citizenshipNo } = req.body;
    
    if (!employeeId) {
        return res.status(400).json({ error: "employeeId is required" });
    }

    try {
        const request = await prisma.profile_update_requests.create({
            data: {
                employee_id: parseInt(employeeId),
                phone: phone || null,
                pan: pan || null,
                citizenship_no: citizenshipNo || null,
                status: "Pending"
            }
        });

        // Create notification for HR
        try {
            const emp = await prisma.employees.findUnique({
                where: { id: parseInt(employeeId) }
            });
            const empName = emp ? `${emp.first_name || ""} ${emp.last_name || ""}`.trim() : `Employee #${employeeId}`;
            await prisma.notifications.create({
                data: {
                    employee_id: null, // null employee_id means for HR
                    title: `New Profile Update Request`,
                    description: `${empName} submitted a request to update legal profile information.`
                }
            });
        } catch (notifErr) {
            console.error("Failed to create HR notification for profile request:", notifErr);
        }

        res.status(201).json({ message: "Profile update request submitted successfully", request });
    } catch (err) {
        console.error("Error submitting profile request:", err);
        res.status(500).json({ error: "Server error" });
    }
});

// 2. Fetch all pending requests for HR view
router.get("/pending", async (req, res) => {
    try {
        const requests = await prisma.profile_update_requests.findMany({
            where: { status: "Pending" },
            orderBy: { created_at: "desc" },
            include: {
                employee: {
                    select: { 
                        first_name: true, 
                        last_name: true,
                        phone: true,
                        pan: true,
                        citizenship_no: true
                    }
                }
            }
        });
        res.status(200).json(requests);
    } catch (err) {
        console.error("Error fetching pending profile requests:", err);
        res.status(500).json({ error: "Server error" });
    }
});

// 3. Update profile request status (HR Approve/Decline)
router.put("/:id/status", async (req, res) => {
    const { id } = req.params;
    const { status } = req.body; // "Approved" or "Declined"

    if (!status || (status !== "Approved" && status !== "Declined")) {
        return res.status(400).json({ error: "Valid status ('Approved' or 'Declined') is required" });
    }

    try {
        const request = await prisma.profile_update_requests.findUnique({
            where: { id: parseInt(id) }
        });

        if (!request) {
            return res.status(404).json({ error: "Request not found" });
        }

        // Update the request status
        const updatedRequest = await prisma.profile_update_requests.update({
            where: { id: parseInt(id) },
            data: { status }
        });

        // If approved, update the employee record
        if (status === "Approved") {
            const updateData = {};
            if (request.phone) updateData.phone = request.phone;
            if (request.pan) updateData.pan = request.pan;
            if (request.citizenship_no) updateData.citizenship_no = request.citizenship_no;

            if (Object.keys(updateData).length > 0) {
                await prisma.employees.update({
                    where: { id: request.employee_id },
                    data: updateData
                });
            }
        }

        // Create notification for employee
        try {
            await prisma.notifications.create({
                data: {
                    employee_id: request.employee_id,
                    title: `Profile Update ${status}`,
                    description: `Your request to update legal profile information has been ${status.toLowerCase()}.`
                }
            });
        } catch (notifErr) {
            console.error("Failed to create profile update notification for employee:", notifErr);
        }

        res.status(200).json({ message: `Request ${status.toLowerCase()} successfully`, request: updatedRequest });
    } catch (err) {
        console.error("Error updating profile request status:", err);
        res.status(500).json({ error: "Server error" });
    }
});

// 4. Directly update personal info (Employee)
router.put("/personal-info/:employeeId", async (req, res) => {
    const { employeeId } = req.params;
    const { city, district, province, ward, maritalStatus, gender } = req.body;

    try {
        const updatedEmployee = await prisma.employees.update({
            where: { id: parseInt(employeeId) },
            data: {
                city: city !== undefined ? city : undefined,
                district: district !== undefined ? district : undefined,
                province: province !== undefined ? province : undefined,
                ward: ward !== undefined ? ward.toString() : undefined,
                marital_status: maritalStatus !== undefined ? maritalStatus : undefined,
                gender: gender !== undefined ? gender : undefined
            }
        });

        res.status(200).json({ message: "Personal information updated successfully", employee: updatedEmployee });
    } catch (err) {
        console.error("Error updating personal info:", err);
        res.status(500).json({ error: "Server error" });
    }
});

module.exports = router;
