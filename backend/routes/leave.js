const express = require("express");
const router = express.Router();
const prisma = require("../prismaClient");

//applting leave
router.post("/", async (req, res) => {
  const { employeeId, leaveType, startDate, endDate, reason } = req.body;
  try {
    const leave = await prisma.leave_requests.create({
      data: {
        employee_id: parseInt(employeeId),
        leave_type: leaveType,
        start_date: new Date(startDate),
        end_date: new Date(endDate),
        reason: reason,
        status: "Pending",
      },
    });
    res.status(201).json({ message: "Leave requested successfully", leave });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Server error" });
  }
});

//get leaves acc to emp ID
router.get("/employee/:id", async (req, res) => {
  const { id } = req.params;
  try {
    const leaves = await prisma.leave_requests.findMany({
      where: { employee_id: parseInt(id) },
      orderBy: { created_at: "desc" },
    });
    res.status(200).json(leaves);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Server error" });
  }
});

//all leaves HR
router.get("/all", async (req, res) => {
  try {

    const leaves = await prisma.leave_requests.findMany({
      include: {
        employee: { select: { first_name: true, last_name: true, job_title: true } },
      },
      orderBy: { created_at: "desc" },
    });
    res.status(200).json(leaves);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Server error" });
  }
});

//leave update
router.put("/:id/status", async (req, res) => {
  const { id } = req.params;
  const { status } = req.body; 
  try {
    const leave = await prisma.leave_requests.update({
      where: { id: parseInt(id) },
      data: { status },
    });
    res.status(200).json({ message: "Status updated", leave });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Server error" });
  }
});

module.exports = router;
