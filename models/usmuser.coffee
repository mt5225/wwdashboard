mongoose = require 'mongoose'
Schema = mongoose.Schema

USMUser = new Schema({}, { strict: false })
module.exports = mongoose.model('USMUser', USMUser)