const mongoose = require('mongoose');

const MedicalSchema = new mongoose.Schema({
    userId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
        required: true
    },
    category: { 
        type: String, 
        enum: ['vaccine', 'medication', 'vital', 'visit'], 
        required: true 
    },
    title: { type: String, required: true }, // e.g., "Rabies Shot" or "Weight Check"
    dateGiven: { type: Date, default: Date.now },
    nextDueDate: { type: Date }, // Optional: For vaccines/meds
    notes: { type: String },
    value: { type: String } // Optional: For vitals (e.g., "12.5 kg")
});

module.exports = mongoose.model('MedicalRecord', MedicalSchema);