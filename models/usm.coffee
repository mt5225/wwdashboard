mongoose = require 'mongoose'
Schema = mongoose.Schema

USM = new Schema({}, { strict: false })
module.exports = mongoose.model('USM', USM)