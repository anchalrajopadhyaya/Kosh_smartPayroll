const prisma = require("../prismaClient");

/**
 * Calculates monthly payroll for an employee.
 * 
 * @param {Object} employee - Employee record
 * @param {number} month - Month (1-12)
 * @param {number} year - Year
 * @returns {Promise<Object>} Calculated payroll data
 */
async function calculateMonthlyPayroll(employee, month, year) {
  const totalSalary = parseFloat(employee.salary) || 0;
  const StandardMonthDays = 30;
  const isIntern = employee.employment_type?.toLowerCase() === 'intern';

  // 1. Get Attendance for the month
  const startDate = new Date(Date.UTC(year, month - 1, 1));
  const endDate = new Date(Date.UTC(year, month, 0)); // Last day of month

  const attendanceCount = await prisma.attendance.count({
    where: {
      employee_id: employee.id,
      date: { gte: startDate, lte: endDate },
      punch_out_time: { not: null } // Only count complete punches
    }
  });

  // 2. Get Approved Leave Days for the month (Paid Leaves)
  const leaves = await prisma.leave_requests.findMany({
    where: {
      employee_id: employee.id,
      status: 'Approved',
      OR: [
        { start_date: { gte: startDate, lte: endDate } },
        { end_date: { gte: startDate, lte: endDate } }
      ]
    }
  });

  let paidLeaveDays = 0;
  leaves.forEach(leave => {
    // Only count days within this specific month
    const lStart = new Date(Math.max(leave.start_date, startDate));
    const lEnd = new Date(Math.min(leave.end_date, endDate));
    const diffTime = Math.abs(lEnd - lStart);
    const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24)) + 1;
    paidLeaveDays += diffDays;
  });

  // calculate Unpaid Leave Days
  let absentDays = StandardMonthDays - attendanceCount - paidLeaveDays;
  if (absentDays < 0) absentDays = 0;
  const unpaidLeaveDays = absentDays;

  //calculations
  const dailyRate = totalSalary / StandardMonthDays;
  const basicSalary = totalSalary * 0.6;
  const basicDailyRate = basicSalary / StandardMonthDays;

  // Unpaid Leave Deduction
  const unpaidLeaveDeduction = dailyRate * unpaidLeaveDays;

  // Gross and Basic Payable
  const grossPayable = totalSalary - unpaidLeaveDeduction;
  const basicPayable = basicSalary - (basicDailyRate * unpaidLeaveDays);

  // SSF Calculations
  let ssfEmployee = 0;
  let ssfEmployer = 0;

  if (!isIntern) {
    ssfEmployee = basicPayable * 0.11;
    ssfEmployer = basicPayable * 0.20;
  }

  // Income Tax (Nepal FY 2080/81)
  let monthlyTax = 0;
  let rebateAmount = 0;

  if (isIntern) {
    //fixed 1% for Interns
    monthlyTax = grossPayable * 0.01;
  } else {
    //progressive tax for Employees
    const annualGross = grossPayable * 12;
    const annualSsf = ssfEmployee * 12;
    const taxableIncome = annualGross - annualSsf;

    let annualTax = 0;
    const maritalStatus = employee.marital_status?.toLowerCase() === 'married' ? 'married' : 'unmarried';
    const gender = employee.gender?.toLowerCase() === 'female' ? 'female' : 'male';

    if (maritalStatus === 'unmarried') {
      if (taxableIncome <= 500000) {
        annualTax = taxableIncome * 0.01;
      } else if (taxableIncome <= 700000) {
        annualTax = (500000 * 0.01) + ((taxableIncome - 500000) * 0.10);
      } else if (taxableIncome <= 1000000) {
        annualTax = (500000 * 0.01) + (200000 * 0.10) + ((taxableIncome - 700000) * 0.20);
      } else if (taxableIncome <= 2000000) {
        annualTax = (500000 * 0.01) + (200000 * 0.10) + (300000 * 0.20) + ((taxableIncome - 1000000) * 0.30);
      } else {
        annualTax = (500000 * 0.01) + (200000 * 0.10) + (300000 * 0.20) + (1000000 * 0.30) + ((taxableIncome - 2000000) * 0.36);
      }
    } else {
      // Married Tax Brackets
      if (taxableIncome <= 600000) {
        annualTax = taxableIncome * 0.01;
      } else if (taxableIncome <= 800000) {
        annualTax = (600000 * 0.01) + ((taxableIncome - 600000) * 0.10);
      } else if (taxableIncome <= 1100000) {
        annualTax = (600000 * 0.01) + (200000 * 0.10) + ((taxableIncome - 800000) * 0.20);
      } else if (taxableIncome <= 2000000) {
        annualTax = (600000 * 0.01) + (200000 * 0.10) + (300000 * 0.20) + ((taxableIncome - 1100000) * 0.30);
      } else {
        annualTax = (600000 * 0.01) + (200000 * 0.10) + (300000 * 0.20) + (900000 * 0.30) + ((taxableIncome - 2000000) * 0.36);
      }
    }

    // 10% Tax Rebate for Unmarried Females
    if (maritalStatus === 'unmarried' && gender === 'female') {
      rebateAmount = annualTax * 0.10;
      annualTax -= rebateAmount;
    }

    monthlyTax = annualTax / 12;
  }

  const netTakeHome = grossPayable - ssfEmployee - monthlyTax;

  return {
    id: employee.id,
    name: `${employee.first_name || ''} ${employee.last_name || ''}`.trim(),
    employeeCode: employee.employee_code,
    totalSalary: totalSalary,
    attendance: attendanceCount,
    paidLeaves: paidLeaveDays,
    unpaidLeaves: unpaidLeaveDays,
    unpaidDeduction: unpaidLeaveDeduction,
    grossPayable: grossPayable,
    ssfEmployee: ssfEmployee,
    ssfEmployer: ssfEmployer,
    tax: monthlyTax,
    rebate: rebateAmount / 12, // monthly rebate
    netSalary: netTakeHome,
    isIntern: isIntern,
    maritalStatus: employee.marital_status,
    gender: employee.gender,
    employmentType: employee.employment_type,
    jobTitle: employee.job_title,
    department: employee.department
  };
}

module.exports = {
  calculateMonthlyPayroll
};
