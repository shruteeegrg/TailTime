const express = require('express');
const router = express.Router();
const Pet = require('../models/Pet');
const ActivityLog = require('../models/ActivityLog'); // Import the new model
const mongoose = require('mongoose');

// 1. ADD A NEW PET
router.post('/add', async (req, res) => {
    try {
        const { ownerId, petName, species, breed, age, weight } = req.body;

        const newPet = new Pet({
            ownerId,
            petName,
            species,
            breed,
            age,
            weight,
            dailySteps: 0,
            dailySleep: 0,
            dailyMeals: 0
        });

        const savedPet = await newPet.save();
        res.status(201).json(savedPet);
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server Error');
    }
});

// 2. GET PET DATA (For Dashboard Card 1)
router.get('/:userId', async (req, res) => {
    try {
        let pet = await Pet.findOne({ ownerId: req.params.userId });
        res.json(pet);
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server Error');
    }
});

// LOG ACTIVITY
router.post('/log-activity', async (req, res) => {
    try {
        const { userId, type, subType, value, duration, date, notes } = req.body;
        
        // A. Save History
        const newLog = new ActivityLog({
            userId, type, subType, value, duration, date, notes
        });
        await newLog.save();

        // B. Update Daily Stats (If Today)
        const isToday = new Date(date).toDateString() === new Date().toDateString();
        if (isToday) {
            let updateField = {};
            // For Walk, we now track Minutes (duration), not steps
            if (type === 'walk') updateField = { dailyWalkMinutes: duration }; 
            if (type === 'sleep') updateField = { dailySleep: value };
            if (type === 'meal') updateField = { dailyMeals: 1 };
            
            // We use $inc to add to the existing total
            await Pet.findOneAndUpdate({ ownerId: userId }, { $inc: updateField });
        }
        res.status(201).json(newLog);
    } catch (err) {
        res.status(500).send(err.message);
    }
});

// GET WEEKLY STATS
router.get('/weekly-stats/:userId/:type', async (req, res) => {
    try {
        const { userId, type } = req.params;
        const sevenDaysAgo = new Date();
        sevenDaysAgo.setDate(sevenDaysAgo.getDate() - 7);

        // Determine what field to sum based on type
        let sumField = "$value"; 
        if (type === 'walk') sumField = "$duration"; // Sum minutes for walks
        if (type === 'meal') sumField = 1; // Just count for meals

        const stats = await ActivityLog.aggregate([
            { 
                $match: { 
                    userId: new mongoose.Types.ObjectId(userId),
                    type: type, 
                    date: { $gte: sevenDaysAgo }
                } 
            },
            {
                $group: {
                    _id: { $dayOfWeek: "$date" }, // 1=Sun...
                    total: { $sum: sumField }
                }
            }
        ]);
        res.json(stats);
    } catch (err) {
        res.status(500).send(err.message);
    }
});

// UPDATE PET DETAILS
router.put('/update/:petId', async (req, res) => {
    try {
        const { petName, breed, age, weight, species } = req.body;
        
        const updatedPet = await Pet.findByIdAndUpdate(
            req.params.petId,
            { 
                $set: { petName, breed, age, weight, species } 
            },
            { new: true } // Return the updated document
        );
        res.json(updatedPet);
    } catch (err) {
        res.status(500).send('Server Error');
    }
});

module.exports = router;