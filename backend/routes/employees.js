const express = require("express");
const router = express.Router();
const pool = require("../db");
const {employeeSchema} = require("./employee_validator");

// Generate employee code
function generateEmployeeCode() {
  const year = new Date().getFullYear();
  const random = Math.floor(1000 + Math.random() * 9000);
  return `EMP-${year}-${random}`;
}

router.post("/employees", async (req, res) => {

  //VALIDATE INPUT USING JOI
  const { error, value } = employeeSchema.validate(req.body, {
    abortEarly: true
  });

  if (error) {
    return res.status(400).json({
      message: error.details[0].message
    });
  }

  //SAFE VALIDATED DATA
  const {
    firstName,
    lastName,
    email,
    phone,
    city,
    district,
    province,
    ward,
    PAN,
    citizenshipNo,
    jobTitle,
    department,
    dob,
    startDate,
    salary,
  } = value;

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
        PAN,
        citizenship_no,
        job_title,
        department,
        dob,
        start_date,
        salary
      )
      VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16)
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
        PAN,
        citizenshipNo,
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

    // Duplicate email handling
    if (err.code === "23505") {
      return res.status(409).json({
        message: "Email already exists"
      });
    }

    console.error(err);
    res.status(500).json({ error: "Server error" });
  }
});

module.exports = router;
