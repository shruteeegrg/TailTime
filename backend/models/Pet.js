const mongoose = require('mongoose');

const PetSchema = new mongoose.Schema({
    ownerId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User', // Links this pet to a specific User
        required: true
    },
    petName: { 
        type: String, 
        required: true 
    },
    species: { 
        type: String, // 'Dog', 'Cat', 'Bird'
        required: true 
    },
    breed: { 
        type: String,
        default: '' 
    },
    age: { 
        type: Number, // Stored as a number (e.g., 2 or 2.5)
        default: 0
    },
    weight: { 
        type: Number, // Stored in kg
        default: 0 
    },
    
    // Daily Activity Stats (For the Dashboard)
    dailySteps: { type: Number, default: 0 },
    dailySleep: { type: Number, default: 0 },
    dailyMeals: { type: Number, default: 0 },

    // Photo (We will implement this later with Firebase Storage)
    photoUrl: {
        type: String,
        default: ''
    },

    createdAt: {
        type: Date,
        default: Date.now
    },

     // Daily Checklist Status (Resets daily - logic for reset is complex, 
    // for this prototype we assume manual reset or reset on new day script)
    tasks: {
        breakfast: { type: Boolean, default: false },
        morningWalk: { type: Boolean, default: false },
        dinner: { type: Boolean, default: false },
        medication: { type: Boolean, default: false }
    },
});

module.exports = mongoose.model('Pet', PetSchema);