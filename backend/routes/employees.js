const express = require("express");
const router = express.Router();
const pool = require("../db");

function generateEmployeeCode() {
  const year = new Date().getFullYear();
  const random = Math.floor(1000 + Math.random() * 9000);
  return `EMP-${year}-${random}`;
}

router.post("/employees", async (req, res) => {
  const {
    firstName,
    lastName,
    email,
    phone,
    city,
    district,
    province,
    ward,
    jobTitle,
    department,
    dob,
    startDate,
    salary,
  } = req.body;

  const employeeCode = generateEmployeeCode();

  try {
    const result = await pool.query(
      `
      INSERT INTO employees (
        employee_code,
        first_name,
        last_name,
        email,
        phone,
        city,
        district,
        province,
        ward,
        job_title,
        department,
        dob,
        start_date,
        salary
      )
      VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14)
      RETURNING employee_code
      `,
      [
        employeeCode,
        firstName,
        lastName,
        email,
        phone,
        city,
        district,
        province,
        ward,
        jobTitle,
        department,
        dob,
        startDate,
        salary,
      ]
    );

    res.status(201).json({
      message: "Employee created",
      employeeCode: result.rows[0].employee_code,
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
