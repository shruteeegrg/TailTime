const express = require('express');
const router = express.Router();
const User = require('../models/User'); // Import the User model

// ------------------------------------------------------------------
// REGISTER ROUTE (The one failing in your logs)
// URL: http://localhost:3000/api/auth/register
// ------------------------------------------------------------------
router.post('/register', async (req, res) => {
    try {
        const { fullName, email, password } = req.body;

        // 1. Check if user already exists
        let user = await User.findOne({ email });
        if (user) {
            return res.status(400).json({ msg: 'User already exists' });
        }

        // 2. Create new user
        user = new User({
            fullName,
            email,
            password
        });

        // 3. Save to MongoDB
        await user.save();

        res.status(201).json({ msg: 'User Registered Successfully', userId: user.id });

    } catch (err) {
        console.error("Register Error:", err.message);
        res.status(500).send('Server Error');
    }
});

// ------------------------------------------------------------------
// LOGIN ROUTE
// URL: http://localhost:3000/api/auth/login
// ------------------------------------------------------------------
router.post('/login', async (req, res) => {
    try {
        const { email, password } = req.body;

        // 1. Check if user exists
        const user = await User.findOne({ email });
        if (!user) {
            return res.status(400).json({ msg: 'User does not exist' });
        }

        // 2. Validate Password
        if (password !== user.password) {
            return res.status(400).json({ msg: 'Invalid credentials' });
        }

        // 3. Login Success
        res.json({ 
            msg: 'Login Successful', 
            user: {
                id: user.id,
                name: user.fullName,
                email: user.email
            }
        });

    } catch (err) {
        console.error("Login Error:", err.message);
        res.status(500).send('Server Error');
    }
});

module.exports = router;