const express = require('express');
const router = express.Router();
const Event = require('../models/Event');

// GET ALL EVENTS for a user
router.get('/:userId', async (req, res) => {
    try {
        const events = await Event.find({ userId: req.params.userId }).sort({ date: 1 });
        res.json(events);
    } catch (err) {
        res.status(500).send('Server Error');
    }
});

// ADD NEW EVENT
router.post('/add', async (req, res) => {
    try {
        const { userId, title, date, type } = req.body;
        
        const newEvent = new Event({
            userId,
            title,
            date,
            type
        });

        const savedEvent = await newEvent.save();
        res.status(201).json(savedEvent);
    } catch (err) {
        res.status(500).send('Server Error');
    }
});

// DELETE EVENT
// URL: http://localhost:3000/api/events/:id
router.delete('/:id', async (req, res) => {
    try {
        const event = await Event.findById(req.params.id);
        if (!event) return res.status(404).json({ msg: 'Event not found' });

        await Event.findByIdAndDelete(req.params.id);
        res.json({ msg: 'Event removed' });
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server Error');
    }
});

module.exports = router;