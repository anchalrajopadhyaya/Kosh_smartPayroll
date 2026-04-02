require('dotenv').config();
const prisma = require('./prismaClient');

async function main() {
    try {
        await prisma.$executeRawUnsafe(`DROP MATERIALIZED VIEW IF EXISTS employee_daily_punches;`);
        await prisma.$executeRawUnsafe(`
            CREATE MATERIALIZED VIEW employee_daily_punches AS
            SELECT 
                employee_id,
                date,
                array_agg(punch_in_time ORDER BY id) as punch_in_times,
                array_agg(punch_out_time ORDER BY id) as punch_out_times
            FROM attendance
            GROUP BY employee_id, date;
        `);
        console.log("Materialized view 'employee_daily_punches' created successfully!");
    } catch (e) {
        console.error("Error creating materialized view:", e);
    } finally {
        await prisma.$disconnect();
    }
}

main();
