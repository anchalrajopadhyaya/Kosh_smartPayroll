const express = require("express");
const router = express.Router();
const prisma = require("../prismaClient");

//submit anonymous feedback
router.post("/", async (req, res) => {
    const { message, category } = req.body;
    try {
        const feedback = await prisma.anonymous_feedback.create({
            data: {
                message: message,
                category: category || "General",
                status: "Unread",
            },
        });
        res.status(201).json({ message: "Feedback submitted securely", feedback });
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: "Server error" });
    }
});

//Fetch all feedbacks
router.get("/all", async (req, res) => {
    try {
        const feedbacks = await prisma.anonymous_feedback.findMany({
            orderBy: { created_at: "desc" },
        });
        res.status(200).json(feedbacks);
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: "Server error" });
    }
});

router.put("/:id/status", async (req, res) => {
    const { id } = req.params;
    const { status } = req.body;

    try {
        const updatedFeedback = await prisma.anonymous_feedback.update({
            where: { id: parseInt(id) },
            data: { status },
        });

        res.status(200).json({ message: "Feedback status updated", feedback: updatedFeedback });
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: "Server error" });
    }
});

module.exports = router;
