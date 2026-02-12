
const express = require("express");
const router = express.Router();
const { validate } = require("../middleware/validation");
const Joi = require("joi");



// Login Schema
const loginSchema = Joi.object({
  email: Joi.string().email().required(),
  password: Joi.string().required(),
});

// Employee Schema (for creation)
const employeeSchema = Joi.object({
  firstName: Joi.string().min(2).max(50).required(),
  lastName: Joi.string().min(2).max(50).required(),
  email: Joi.string().email().required(),
  phone: Joi.string().pattern(/^[0-9]{10}$/).required(),
  city: Joi.string().required(),
  district: Joi.string().required(),
  province: Joi.string().required(),
  ward: Joi.number().integer().required(),
  PAN: Joi.string().optional(),
  citizenshipNo: Joi.string().required(),
  jobTitle: Joi.string().required(),
  department: Joi.string().required(),
  dob: Joi.date().iso().required(),
  startDate: Joi.date().iso().required(),
  password: Joi.string().min(6).required(),
  salary: Joi.number().positive().required(),
});

// Validate Query Parameters
const queryParamsSchema = Joi.object({
  page: Joi.number().integer().min(1).default(1),
  limit: Joi.number().integer().min(1).max(100).default(10),
  sortBy: Joi.string().valid("name", "date", "salary").default("date"),
});

// Middleware to validate query params
const validateQuery = (schema) => {
  return (req, res, next) => {
    const { error, value } = schema.validate(req.query, {
      abortEarly: false,
      stripUnknown: true,
    });

    if (error) {
      const errorMessages = error.details.map((detail) => ({
        field: detail.path.join("."),
        message: detail.message,
      }));

      return res.status(400).json({
        message: "Query validation error",
        errors: errorMessages,
      });
    }

    req.query = value;
    next();
  };
};

// Usage example
router.get("/employees", validateQuery(queryParamsSchema), async (req, res) => {
  const { page, limit, sortBy } = req.query;
  // Use validated query params
  res.json({ page, limit, sortBy });
});

// Validate Route Parameters

const idParamSchema = Joi.object({
  id: Joi.number().integer().positive().required(),
});

const validateParams = (schema) => {
  return (req, res, next) => {
    const { error, value } = schema.validate(req.params, {
      abortEarly: false,
    });

    if (error) {
      const errorMessages = error.details.map((detail) => ({
        field: detail.path.join("."),
        message: detail.message,
      }));

      return res.status(400).json({
        message: "Parameter validation error",
        errors: errorMessages,
      });
    }

    req.params = value;
    next();
  };
};

// Usage example
router.get(
  "/employees/:id",
  validateParams(idParamSchema),
  async (req, res) => {
    const { id } = req.params;
    // Use validated param
    res.json({ id });
  }
);

//Update Employee Schema

const updateEmployeeSchema = Joi.object({
  firstName: Joi.string().min(2).max(50),
  lastName: Joi.string().min(2).max(50),
  email: Joi.string().email(),
  phone: Joi.string().pattern(/^[0-9]{10}$/),
  jobTitle: Joi.string().max(100),
  department: Joi.string().max(50),
  salary: Joi.number().positive().precision(2),
}).min(1); // At least one field must be provided

router.put(
  "/employees/:id",
  validateParams(idParamSchema),
  validate(updateEmployeeSchema),
  async (req, res) => {
    const { id } = req.params;
    const updateData = req.body;
    // Both params and body are validated
    res.json({ message: "Employee updated", id, updateData });
  }
);

module.exports = {
  loginSchema,
  employeeSchema,
  queryParamsSchema,
  idParamSchema,
  updateEmployeeSchema,
  validateQuery,
  validateParams
};
