import { prisma } from './src/prisma'

async function main() {
  // Example: Fetch all records from a table
  // Replace 'user' with your actual model name
  const allEmployees = await prisma.employees.findMany()
  console.log('All employees:', JSON.stringify(allEmployees, null, 2))

  const allUsers = await prisma.users.findMany()
  console.log('All users:', JSON.stringify(allUsers, null, 2))
}

main()
  .then(async () => {
    await prisma.$disconnect()
  })
  .catch(async (e) => {
    console.error(e)
    await prisma.$disconnect()
    process.exit(1)
  })