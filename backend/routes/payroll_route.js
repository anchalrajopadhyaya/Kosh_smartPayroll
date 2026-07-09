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

const nodemailer = require("nodemailer");

// Nodemailer transporter setup using environment variables
const transporter = nodemailer.createTransport({
  service: "gmail",
  auth: {
    user: process.env.SMTP_USER,
    pass: process.env.SMTP_PASS,
  },
});

// POST /api/payroll/formula-request
router.post("/formula-request", async (req, res) => {
  const { ruleTitle, description, hrName, hrEmail } = req.body;

  if (!ruleTitle || !description) {
    return res.status(400).json({ error: "Rule title and description are required" });
  }

  try {
    const mailOptions = {
      from: process.env.SMTP_USER,
      to: "chinx062@gmail.com",
      subject: `[Kosh Payroll] Salary Formula Change Request: ${ruleTitle}`,
      html: `
        <div style="font-family: Arial, sans-serif; max-width: 600px; margin: auto; border: 1px solid #e0e0e0; border-radius: 8px; padding: 24px;">
          <h2 style="color: #188984; border-bottom: 2px solid #188984; padding-bottom: 8px; margin-top: 0;">Salary Formula Change Request</h2>
          <p style="font-size: 14px; color: #555;">A request has been submitted by HR to update the salary calculation logic.</p>
          <table style="width: 100%; border-collapse: collapse; margin: 16px 0;">
            <tr>
              <td style="padding: 8px 0; font-weight: bold; color: #333; width: 130px;">HR User:</td>
              <td style="padding: 8px 0; color: #555;">${hrName || 'HR'} (${hrEmail || 'N/A'})</td>
            </tr>
            <tr>
              <td style="padding: 8px 0; font-weight: bold; color: #333;">Rule Category:</td>
              <td style="padding: 8px 0; color: #555;">${ruleTitle}</td>
            </tr>
          </table>
          <p style="font-weight: bold; color: #333; margin-bottom: 8px;">Requested Updates:</p>
          <div style="background-color: #f8f9fa; border-left: 4px solid #188984; padding: 16px; font-family: monospace; white-space: pre-wrap; color: #333; border-radius: 4px;">
            ${description}
          </div>
          <p style="font-size: 12px; color: #888; margin-top: 24px; border-top: 1px solid #eee; padding-top: 12px;">This request was generated automatically from the Kosh Payroll Management System.</p>
        </div>
      `,
    };

    await transporter.sendMail(mailOptions);
    res.status(200).json({ message: "Formula change request sent to the development team successfully." });
  } catch (err) {
    console.error("Failed to send salary formula update email:", err);
    res.status(500).json({ error: "Failed to send notification email." });
  }
});

// POST /api/payroll/pay
router.post("/pay", async (req, res) => {
  const { employeeId, amount, month, year } = req.body;
  if (!employeeId || !amount || !month || !year) {
    return res.status(400).json({ error: "Missing required parameters" });
  }

  try {
    const employee = await prisma.employees.findUnique({
      where: { id: parseInt(employeeId) }
    });

    if (!employee) {
      return res.status(404).json({ error: "Employee not found" });
    }

    const monthNames = [
      "January", "February", "March", "April", "May", "June",
      "July", "August", "September", "October", "November", "December"
    ];
    const monthName = monthNames[month - 1] || `Month ${month}`;

    //create a notification for the employee
    await prisma.notifications.create({
      data: {
        employee_id: parseInt(employeeId),
        title: "Salary Paid",
        description: `Your salary of NPR ${parseFloat(amount).toFixed(2)} for ${monthName} ${year} has been paid successfully.`
      }
    });

    res.status(200).json({
      success: true,
      message: `Salary of NPR ${parseFloat(amount).toFixed(2)} paid to ${employee.first_name} ${employee.last_name}`
    });
  } catch (err) {
    console.error("Error processing payment:", err);
    res.status(500).json({ error: "Server error processing payment" });
  }
});

module.exports = router;
