import { PrismaClient } from "@prisma/config";
import bcrypt from "bcrypt";

const prisma = new PrismaClient();

async function main() {
  const name = "Admin";
  const email = "admin@gmail.com";
  const password = "admin123";

  const hashedPassword = await bcrypt.hash(password, 10);

  const user = await prisma.users.upsert({
    where: { email },
    update: { password: hashedPassword },
    create: { name, email, password: hashedPassword },
  });

  console.log("Inserted/Updated user:", user);
}

main()
  .catch(console.error)
  .finally(() => prisma.$disconnect());
