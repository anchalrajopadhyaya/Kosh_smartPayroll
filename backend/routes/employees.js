const express = require("express");
const router = express.Router();
const prisma = require("../prismaClient");
const bcrypt = require("bcrypt");
const { employeeSchema } = require("./employee_validator");
const { validate } = require("../middleware/validation");

// Generate employee code
function generateEmployeeCode() {
  const year = new Date().getFullYear();
  const random = Math.floor(1000 + Math.random() * 9000);
  return `EMP-${year}-${random}`;
}

// Create new employee - Using middleware for validation
router.post("/employees", validate(employeeSchema), async (req, res) => {
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
    password,
    salary,
  } = req.body; //validated by middleware

  const employeeCode = generateEmployeeCode();

  try {
    const hashedPassword = await bcrypt.hash(password, 10);

    const newEmployee = await prisma.employees.create({
      data: {
        employee_code: employeeCode,
        first_name: firstName,
        last_name: lastName,
        email: email,
        phone: phone,
        city: city,
        district: district,
        province: province,
        ward: ward.toString(), 
        pan: PAN,
        citizenship_no: citizenshipNo,
        job_title: jobTitle,
        department: department,
        dob: new Date(dob),
        start_date: new Date(startDate),
        password: hashedPassword,
        salary: salary,
      }
    });

    res.status(201).json({
      message: "Employee created",
      employeeCode: newEmployee.employee_code,
    });
  } catch (err) {
    if (err.code === "P2002") { // Prisma unique constraint violation code
      return res.status(409).json({
        message: "Email or other unique field already exists",
      });
    }

    console.error(err);
    res.status(500).json({ error: "Server error" });
  }
});

// Get employee details
router.get("/employees", async (req, res) => {
  try {
    const employees = await prisma.employees.findMany({
      orderBy: {
        created_at: 'desc',
      },
      select: {
        id: true,
        employee_code: true,
        first_name: true,
        last_name: true,
        email: true,
        phone: true,
        city: true,
        district: true,
        province: true,
        ward: true,
        job_title: true,
        department: true,
        salary: true,
        dob: true,
        start_date: true,
        created_at: true,
      }
    });

    res.status(200).json({
      message: "Employees retrieved successfully",
      employees: employees,
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Server error" });
  }
});

module.exports = router;