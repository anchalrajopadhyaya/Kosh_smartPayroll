const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

async function checkData() {
    const attendanceCount = await prisma.attendance.count();
    const employeeCount = await prisma.employees.count();
    const allAttendance = await prisma.attendance.findMany({
        take: 5,
        include: { employee: true }
    });

    console.log('Attendance Count:', attendanceCount);
    console.log('Employee Count:', employeeCount);
    console.log('Sample Attendance:', JSON.stringify(allAttendance, null, 2));

    await prisma.$disconnect();
}

checkData();
