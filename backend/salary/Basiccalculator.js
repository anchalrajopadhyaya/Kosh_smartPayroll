const readline = require('readline');

const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout
});

const question = (query) => new Promise((resolve) => rl.question(query, resolve));

async function calculateSalary() {
    console.log("\n=== Salary & SSF Calculator ===\n");

    try {
        const totalSalaryInput = await question("Enter Monthly Total Salary (NPR): ");
        const attendedDaysInput = await question("Enter Attended Days: ");
        const paidLeaveDaysInput = await question("Enter Paid Leave Days (or 0): ");
        const unpaidLeaveDaysInput = await question("Enter Unpaid Leave Days (Press Enter to auto-calculate): ");
        const maritalStatusInput = await question("Enter Marital Status (unmarried/married): ");
        const genderInput = await question("Enter Gender (male/female): ");

        const totalSalary = parseFloat(totalSalaryInput);
        const attendedDays = parseFloat(attendedDaysInput);
        const paidLeaveDays = parseFloat(paidLeaveDaysInput) || 0;
        const maritalStatus = maritalStatusInput.trim().toLowerCase() === 'married' ? 'married' : 'unmarried';
        const gender = genderInput.trim().toLowerCase() === 'female' ? 'female' : 'male';

        if (isNaN(totalSalary) || isNaN(attendedDays)) {
            console.error("\nError: Please enter valid numbers for salary and attended days.\n");
            rl.close();
            return;
        }

        const StandardMonthDays = 30;

        // Calculate Unpaid Leave Days (Standard 30 days)
        let unpaidLeaveDays = parseFloat(unpaidLeaveDaysInput);
        if (isNaN(unpaidLeaveDays)) {
            let absentDays = StandardMonthDays - attendedDays - paidLeaveDays;
            if (absentDays < 0) absentDays = 0;
            unpaidLeaveDays = absentDays;
        }

        // 1. Formulas
        const dailyRate = totalSalary / StandardMonthDays;

        // Basic Salary is usually 60% of Total Gross Salary in Nepal
        const basicSalary = totalSalary * 0.6;
        const basicDailyRate = basicSalary / StandardMonthDays;

        // Unpaid Leave Deduction
        const unpaidLeaveDeduction = dailyRate * unpaidLeaveDays;

        // Pro-rated Salary
        // Logic: Gross Payable = Monthly Total - Deduction for unpaid days
        const grossPayable = totalSalary - unpaidLeaveDeduction;
        const basicPayable = basicSalary - (basicDailyRate * unpaidLeaveDays);

        // Social Security Fund (SSF) Calculations
        // Employee Contribution: 11% of Basic Payable
        // Employer Contribution: 20% of Basic Payable
        const ssfEmployee = basicPayable * 0.11;
        const ssfEmployer = basicPayable * 0.20;
        const totalSsf = ssfEmployee + ssfEmployer;

        // --- NEW TAX LOGIC (Nepal FY 2080/81) ---
        const annualGross = grossPayable * 12;
        const annualSsf = ssfEmployee * 12;
        let taxableIncome = annualGross - annualSsf;

        let annualTax = 0;

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

        // Apply 10% Tax Rebate for Unmarried Females
        let rebateAmount = 0;
        if (maritalStatus === 'unmarried' && gender === 'female') {
            rebateAmount = annualTax * 0.10;
            annualTax -= rebateAmount;
        }

        const monthlyTax = annualTax / 12;
        const netTakeHome = grossPayable - ssfEmployee - monthlyTax;

        // 2. Output in Table Format
        const results = [
            { Description: 'Total Monthly Salary', Amount: totalSalary.toFixed(2) },
            { Description: 'Basic Salary (60%)', Amount: basicSalary.toFixed(2) },
            { Description: 'Attended Days', Amount: attendedDays.toFixed(2) },
            { Description: 'Paid Leave Days', Amount: paidLeaveDays.toFixed(2) },
            { Description: 'Unpaid Leave Days', Amount: unpaidLeaveDays.toFixed(2) },
            { Description: 'Unpaid Leave Deduction', Amount: `-${unpaidLeaveDeduction.toFixed(2)}` },
            { Description: 'Gross Payable (After Deduction)', Amount: grossPayable.toFixed(2) },
            { Description: 'Basic Payable (After Deduction)', Amount: basicPayable.toFixed(2) },
            { Description: 'SSF Employee (11%)', Amount: `-${ssfEmployee.toFixed(2)}` },
            { Description: 'SSF Employer (Company Funded 20%)', Amount: `+${ssfEmployer.toFixed(2)}` },
            { Description: 'Female Tax Rebate (Annual)', Amount: `-${rebateAmount.toFixed(2)}` },
            { Description: 'Income Tax (Monthly)', Amount: `-${monthlyTax.toFixed(2)}` },
            { Description: 'Net Take Home Salary', Amount: netTakeHome.toFixed(2) }
        ];

        console.log("\nCalculation Results:\n");
        console.table(results);

        console.log("\nSummary:");
        console.log(`- Attended: ${attendedDays} days`);
        console.log(`- Paid Leave: ${paidLeaveDays} days`);
        console.log(`- Unpaid Leave: ${unpaidLeaveDays} days (Deducted)`);
        console.log(`- Marital Status: ${maritalStatus.toUpperCase()}`);
        console.log(`- Gender: ${gender.toUpperCase()}`);

    } catch (err) {
        console.error("An error occurred:", err);
    } finally {
        rl.close();
    }
}

calculateSalary();
