const express = require("express");
const router = express.Router();
const prisma = require("../prismaClient");

//GET notifications for employee or HR
router.get("/:employeeId", async (req, res) => {
    const { employeeId } = req.params;
    try {
        let list;
        if (employeeId.toLowerCase() === "hr") {
            list = await prisma.notifications.findMany({
                where: { employee_id: null },
                orderBy: { created_at: "desc" }
            });
        } else {
            list = await prisma.notifications.findMany({
                where: { employee_id: parseInt(employeeId) },
                orderBy: { created_at: "desc" }
            });
        }
        res.status(200).json(list);
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: "Server error" });
    }
});

//PUT mark notification as read
router.put("/:id/read", async (req, res) => {
    const { id } = req.params;
    try {
        const updated = await prisma.notifications.update({
            where: { id: parseInt(id) },
            data: { is_read: true }
        });
        res.status(200).json({ message: "Notification marked as read", notification: updated });
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: "Server error" });
    }
});

//POST create system notification
router.post("/", async (req, res) => {
    const { employeeId, title, description } = req.body;
    if (!employeeId || !title || !description) {
        return res.status(400).json({ error: "employeeId, title, and description are required" });
    }
    try {
        const item = await prisma.notifications.create({
            data: {
                employee_id: parseInt(employeeId),
                title,
                description
            }
        });
        res.status(201).json({ message: "Notification created", notification: item });
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: "Server error" });
    }
});

module.exports = router;
