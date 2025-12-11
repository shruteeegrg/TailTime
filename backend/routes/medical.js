const express = require('express');
const router = express.Router();
const MedicalRecord = require('../models/MedicalRecord');

// GET RECORDS (Filtered by Category is handled on Frontend for simplicity, or here)
router.get('/:userId', async (req, res) => {
    try {
        const records = await MedicalRecord.find({ userId: req.params.userId }).sort({ dateGiven: -1 });
        res.json(records);
    } catch (err) {
        res.status(500).send('Server Error');
    }
});

// ADD RECORD
router.post('/add', async (req, res) => {
    try {
        const { userId, category, title, dateGiven, nextDueDate, notes, value } = req.body;
        
        const newRecord = new MedicalRecord({
            userId,
            category,
            title,
            dateGiven,
            nextDueDate,
            notes,
            value
        });

        await newRecord.save();
        res.status(201).json(newRecord);
    } catch (err) {
        res.status(500).send('Server Error');
    }
});

module.exports = router;