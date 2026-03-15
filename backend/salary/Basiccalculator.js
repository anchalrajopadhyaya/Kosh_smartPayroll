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
        const paidLeaveDaysInput = await question("Enter Paid Leave Days: ");

        const totalSalary = parseFloat(totalSalaryInput);
        const attendedDays = parseFloat(attendedDaysInput);
        const paidLeaveDays = parseFloat(paidLeaveDaysInput);

        if (isNaN(totalSalary) || isNaN(attendedDays) || isNaN(paidLeaveDays)) {
            console.error("\nError: Please enter valid numbers for all inputs.\n");
            rl.close();
            return;
        }

        //Formulas
        const basicSalary = totalSalary * 0.6;

        //Payable Days
        const totalPayableDays = attendedDays + paidLeaveDays;

        const grossPayable = (totalSalary / 30) * totalPayableDays;
        const basicPayable = (basicSalary / 30) * totalPayableDays;

        //SSF Calculations
        const ssfEmployee = basicPayable * 0.11;
        const ssfEmployer = basicPayable * 0.20;
        const totalSsf = ssfEmployee + ssfEmployer;

        //Net Salary
        const netTakeHome = grossPayable - ssfEmployee;

        const results = [
            { Description: 'Total Monthly Salary', Amount: totalSalary.toFixed(2) },
            { Description: 'Basic Salary (60%)', Amount: basicSalary.toFixed(2) },
            { Description: 'Total Payable Days', Amount: totalPayableDays.toFixed(2) },
            { Description: 'Gross Payable', Amount: grossPayable.toFixed(2) },
            { Description: 'Basic Payable', Amount: basicPayable.toFixed(2) },
            { Description: 'SSF Employee (11%)', Amount: ssfEmployee.toFixed(2) },
            { Description: 'SSF Employer (20%)', Amount: ssfEmployer.toFixed(2) },
            { Description: 'Total SSF Contribution', Amount: totalSsf.toFixed(2) },
            { Description: 'Net Take Home Salary', Amount: netTakeHome.toFixed(2) }
        ];

        console.log("\nCalculation Results:\n");
        console.table(results);

        console.log("\nSummary:");
        console.log(`- Attended: ${attendedDays} days`);
        console.log(`- Paid Leave: ${paidLeaveDays} days`);
        console.log(`- Total Payable: ${totalPayableDays} days`);

    } catch (err) {
        console.error("An error occurred:", err);
    } finally {
        rl.close();
    }
}

calculateSalary();
