const mongoose = require('mongoose');

const ActivityLogSchema = new mongoose.Schema({
    userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
    type: { 
        type: String, 
        enum: ['walk', 'sleep', 'meal'], 
        required: true 
    },
    subType: { type: String }, // NEW: Stores 'Breakfast', 'Lunch', etc.
    value: { type: Number, required: true }, // Count (1 for meal) or Hours (sleep)
    duration: { type: Number, default: 0 },  // NEW: Minutes (for walks)
    date: { type: Date, required: true },
    notes: { type: String }
});

module.exports = mongoose.model('ActivityLog', ActivityLogSchema);