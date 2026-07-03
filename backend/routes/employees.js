const express = require("express");
const router = express.Router();
const prisma = require("../prismaClient");
const bcrypt = require("bcrypt");
const { employeeSchema } = require("./employee_validator");
const { validate } = require("../middleware/validation");

//Generate employee code
function generateEmployeeCode() {
  const year = new Date().getFullYear();
  const random = Math.floor(1000 + Math.random() * 9000);
  return `EMP-${year}-${random}`;
}

//Create new employee - Using middleware for validation
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
    maritalStatus,
    gender,
    employmentType,
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
        marital_status: maritalStatus || "unmarried",
        gender: gender || "other",
        employment_type: employmentType || "Full-Time",
        must_change_password: true,
      }
    });

    res.status(201).json({
      message: "Employee created",
      employeeCode: newEmployee.employee_code,
    });
  } catch (err) {
    if (err.code === "P2002") { //Prisma unique constraint violation code
      return res.status(409).json({
        message: "Email or other unique field already exists",
      });
    }

    console.error(err);
    res.status(500).json({ error: "Server error" });
  }
});

//Get employee details
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
        marital_status: true,
        gender: true,
        employment_type: true,
        dob: true,
        start_date: true,
        created_at: true,
        pan: true,
        citizenship_no: true,
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

//Get employee by email (used for HR personal view lookup)
router.get("/employees/by-email/:email", async (req, res) => {
  const { email } = req.params;
  try {
    const employee = await prisma.employees.findUnique({
      where: { email: email },
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
        marital_status: true,
        gender: true,
        employment_type: true,
        dob: true,
        start_date: true,
        created_at: true,
        pan: true,
        citizenship_no: true,
      }
    });

    if (!employee) {
      return res.status(404).json({ message: "Employee not found" });
    }

    res.status(200).json(employee);
  } catch (err) {
    console.error("Error fetching employee by email:", err);
    res.status(500).json({ error: "Server error fetching employee" });
  }
});

//Get specific employee by ID
router.get("/employees/:id", async (req, res) => {
  const { id } = req.params;
  try {
    const employee = await prisma.employees.findUnique({
      where: { id: parseInt(id) },
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
        marital_status: true,
        gender: true,
        employment_type: true,
        dob: true,
        start_date: true,
        created_at: true,
        pan: true,
        citizenship_no: true,
      }
    });

    if (!employee) {
      return res.status(404).json({ message: "Employee not found" });
    }

    res.status(200).json(employee);
  } catch (err) {
    console.error("Error fetching employee:", err);
    res.status(500).json({ error: "Server error fetching employee" });
  }
});

//Delete employee and dependencies
router.delete("/employees/:id", async (req, res) => {
  const { id } = req.params;
  const empId = parseInt(id);

  try {
    const employee = await prisma.employees.findUnique({
      where: { id: empId }
    });

    if (!employee) {
      return res.status(404).json({ message: "Employee not found" });
    }

    // Delete in dependency order using transaction
    await prisma.$transaction([
      prisma.attendance.deleteMany({ where: { employee_id: empId } }),
      prisma.leave_requests.deleteMany({ where: { employee_id: empId } }),
      prisma.time_requests.deleteMany({ where: { employee_id: empId } }),
      prisma.notifications.deleteMany({ where: { employee_id: empId } }),
      prisma.profile_update_requests.deleteMany({ where: { employee_id: empId } }),
      prisma.employees.delete({ where: { id: empId } })
    ]);

    res.status(200).json({ message: "Employee deleted successfully" });
  } catch (err) {
    console.error("Error deleting employee:", err);
    res.status(500).json({ error: "Server error deleting employee" });
  }
});

module.exports = router;