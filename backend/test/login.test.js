const request = require('supertest');
const app = require('../app');
const prisma = require('../prismaClient');
const bcrypt = require('bcrypt');

describe('POST /login', () => {

    beforeEach(async () => {
        await prisma.users.deleteMany();
        await prisma.employees.deleteMany();
    });

    afterAll(async () => {
        await prisma.$disconnect();
    });

    it('should login HR user', async () => {
        const hashedPassword = await bcrypt.hash("password123", 10);

        await prisma.users.create({
            data: {
                name: "HR Admin",
                email: "hr@test.com",
                password: hashedPassword,
                role: "hr"
            }
        });

        const res = await request(app)
            .post('/login')
            .send({
                email: "hr@test.com",
                password: "password123"
            });

        expect(res.statusCode).toBe(200);
        expect(res.body.userType).toBe("hr");
    });

    it('should login employee', async () => {
        const hashedPassword = await bcrypt.hash("password123", 10);

        await prisma.employees.create({
            data: {
                employee_code: "EMP-1234",
                first_name: "John",
                last_name: "Doe",
                email: "emp@test.com",
                password: hashedPassword,
                phone: "123456789",
                city: "Kathmandu",
                district: "Kathmandu",
                province: "Bagmati",
                ward: "1",
                pan: "123",
                citizenship_no: "ABC",
                job_title: "Dev",
                department: "IT",
                dob: new Date(),
                start_date: new Date(),
                salary: 50000,
            }
        });

        const res = await request(app)
            .post('/login')
            .send({
                email: "emp@test.com",
                password: "password123"
            });

        expect(res.statusCode).toBe(200);
        expect(res.body.userType).toBe("employee");
    });

    it('should fail with wrong password', async () => {
        const res = await request(app)
            .post('/login')
            .send({
                email: "wrong@test.com",
                password: "wrong"
            });

        expect(res.statusCode).toBe(401);
    });

});