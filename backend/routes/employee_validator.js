const Joi = require("joi");

const employeeSchema = Joi.object({
  firstName: Joi.string().min(2).max(50).required(),
  lastName: Joi.string().min(2).max(50).required(),

  email: Joi.string().email().required(),

  phone: Joi.string()
    .pattern(/^[0-9]{7,15}$/)
    .required(),

  city: Joi.string().max(50).required(),
  district: Joi.string().max(50).required(),
  province: Joi.string().max(50).required(),
  ward: Joi.string().max(10).required(),

  PAN: Joi.string().max(20).allow(null, ""),
  citizenshipNo: Joi.string().max(50).allow(null, ""),

  jobTitle: Joi.string().max(100).required(),
  department: Joi.string().max(50).required(),

  dob: Joi.date().less("now").required(),
  startDate: Joi.date().required(),

  salary: Joi.number().positive().precision(2).required()
});

// Add login schema
const loginSchema = Joi.object({
  email: Joi.string().email().required(),
  password: Joi.string().min(6).required()
});

// Export both schemas
module.exports = { employeeSchema, loginSchema };
