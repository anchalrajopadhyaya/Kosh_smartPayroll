const express = require("express");
const router = express.Router();
const prisma = require("../prismaClient");
const { calculateMonthlyPayroll } = require("../utils/payroll");

// GET /api/payroll/calculate/:employeeId?month=M&year=Y
router.get("/calculate/:employeeId", async (req, res) => {
  const { employeeId } = req.params;
  const month = parseInt(req.query.month) || (new Date().getMonth() + 1);
  const year = parseInt(req.query.year) || new Date().getFullYear();

  try {
    const employee = await prisma.employees.findUnique({
      where: { id: parseInt(employeeId) }
    });

    if (!employee) {
      return res.status(404).json({ message: "Employee not found" });
    }

    const payroll = await calculateMonthlyPayroll(employee, month, year);
    res.status(200).json(payroll);
  } catch (err) {
    console.error("Error calculating payroll:", err);
    res.status(500).json({ error: "Server error calculating payroll" });
  }
});

// GET /api/payroll/monthly-summary?month=M&year=Y
router.get("/monthly-summary", async (req, res) => {
  const month = parseInt(req.query.month) || (new Date().getMonth() + 1);
  const year = parseInt(req.query.year) || new Date().getFullYear();

  try {
    const employees = await prisma.employees.findMany({
      where: {
        salary: { not: null }
      }
    });

    let totalPayouts = 0;
    let taxWithheld = 0;
    let ssfEmployer = 0;
    let approvedLeaves = 0;
    const individualDetails = [];

    for (const employee of employees) {
      const payroll = await calculateMonthlyPayroll(employee, month, year);
      totalPayouts += payroll.netSalary;
      taxWithheld += payroll.tax;
      ssfEmployer += payroll.ssfEmployer;
      approvedLeaves += payroll.paidLeaves;
      individualDetails.push(payroll);
    }

    res.status(200).json({
      month,
      year,
      totalPayouts: parseFloat(totalPayouts.toFixed(2)),
      taxWithheld: parseFloat(taxWithheld.toFixed(2)),
      ssfEmployer: parseFloat(ssfEmployer.toFixed(2)),
      approvedLeaves: Math.round(approvedLeaves),
      employeeCount: employees.length,
      details: individualDetails
    });
  } catch (err) {
    console.error("Error calculating monthly summary:", err);
    res.status(500).json({ error: "Server error calculating monthly summary" });
  }
});

module.exports = router;
