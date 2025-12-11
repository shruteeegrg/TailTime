const express = require('express');
const router = express.Router();
const User = require('../models/User');

// GET USER PROFILE (and Settings)
router.get('/:id', async (req, res) => {
    try {
        const user = await User.findById(req.params.id).select('-password'); // Don't send password back
        if (!user) return res.status(404).json({ msg: 'User not found' });
        res.json(user);
    } catch (err) {
        res.status(500).send('Server Error');
    }
});

// UPDATE SETTINGS
router.put('/settings', async (req, res) => {
    try {
        const { userId, settings } = req.body;
        const user = await User.findByIdAndUpdate(
            userId,
            { $set: { settings: settings } },
            { new: true }
        ).select('-password');
        res.json(user);
    } catch (err) {
        res.status(500).send('Server Error');
    }
});

// CHANGE PASSWORD
router.put('/change-password', async (req, res) => {
    try {
        const { userId, newPassword } = req.body;
        
        await User.findByIdAndUpdate(userId, { password: newPassword });
        
        res.json({ msg: "Password Updated" });
    } catch (err) {
        res.status(500).send('Server Error');
    }
});

module.exports = router;