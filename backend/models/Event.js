const mongoose = require('mongoose');

const EventSchema = new mongoose.Schema({
    userId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
        required: true
    },
    title: { type: String, required: true }, // e.g., "Rabies Shot"
    date: { type: Date, required: true },    // The specific date
    type: { 
        type: String, 
        enum: ['vet', 'grooming', 'medication', 'other'],
        default: 'other' 
    },
    isCompleted: { type: Boolean, default: false }
});

module.exports = mongoose.model('Event', EventSchema);