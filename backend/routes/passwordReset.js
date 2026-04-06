const express = require("express");
const router = express.Router();
const prisma = require("../prismaClient");
const bcrypt = require("bcrypt");
const nodemailer = require("nodemailer");

// Nodemailer setup
const transporter = nodemailer.createTransport({
  service: "gmail",
  auth: {
    user: process.env.SMTP_USER,
    pass: process.env.SMTP_PASS,
  },
});

// Helper to generate a 6-digit OTP
const generateOTP = () => {
  return Math.floor(100000 + Math.random() * 900000).toString();
};

// 1. Forgot Password - Generate OTP
router.post("/forgot-password", async (req, res) => {
  const { email } = req.body;

  if (!email) {
    return res.status(400).json({ message: "Email is required" });
  }

  try {
    // Check if user exists in employees or users
    const employee = await prisma.employees.findUnique({ where: { email } });
    const user = await prisma.users.findUnique({ where: { email } });

    if (!employee && !user) {
      return res.status(404).json({ message: "No account found with this email" });
    }

    const otp = generateOTP();
    const expiresAt = new Date(Date.now() + 10 * 60000); // 10 minutes expiry

    // Delete any existing OTPs for this email to prevent spam
    await prisma.password_resets.deleteMany({ where: { email } });

    // Store new OTP
    await prisma.password_resets.create({
      data: {
        email,
        otp,
        expires_at: expiresAt,
      },
    });

    // Send Email
    const mailOptions = {
      from: process.env.SMTP_USER,
      to: email,
      subject: "Your Password Reset OTP",
      text: `Your One-Time Password for resetting your password is: ${otp}. It is valid for 10 minutes.`,
    };

    await transporter.sendMail(mailOptions);

    return res.status(200).json({ message: "OTP sent successfully" });
  } catch (err) {
    console.error("Forgot password error:", err);
    return res.status(500).json({ message: "Server error" });
  }
});

// 2. Verify OTP
router.post("/verify-otp", async (req, res) => {
  const { email, otp } = req.body;

  if (!email || !otp) {
    return res.status(400).json({ message: "Email and OTP are required" });
  }

  try {
    const resetRecord = await prisma.password_resets.findFirst({
      where: { email, otp },
    });

    if (!resetRecord) {
      return res.status(400).json({ message: "Invalid or expired OTP" });
    }

    if (resetRecord.expires_at < new Date()) {
      return res.status(400).json({ message: "OTP has expired" });
    }

    return res.status(200).json({ message: "OTP verified successfully" });
  } catch (err) {
    console.error("Verify OTP error:", err);
    return res.status(500).json({ message: "Server error" });
  }
});

// 3. Reset Password
router.post("/reset-password", async (req, res) => {
  const { email, otp, newPassword } = req.body;

  if (!email || !otp || !newPassword) {
    return res.status(400).json({ message: "Email, OTP, and new password are required" });
  }

  try {
    // Verify OTP again just to be safe
    const resetRecord = await prisma.password_resets.findFirst({
      where: { email, otp },
    });

    if (!resetRecord || resetRecord.expires_at < new Date()) {
      return res.status(400).json({ message: "Invalid or expired OTP" });
    }

    // Hash the new password
    const hashedPassword = await bcrypt.hash(newPassword, 10);

    // Update password in the correct table
    const employee = await prisma.employees.findUnique({ where: { email } });
    
    if (employee) {
      await prisma.employees.update({
        where: { email },
        data: { password: hashedPassword },
      });
    } else {
      await prisma.users.update({
        where: { email },
        data: { password: hashedPassword },
      });
    }

    // Cleanup OTP
    await prisma.password_resets.deleteMany({ where: { email } });

    return res.status(200).json({ message: "Password updated successfully" });
  } catch (err) {
    console.error("Reset password error:", err);
    return res.status(500).json({ message: "Server error" });
  }
});

module.exports = router;
