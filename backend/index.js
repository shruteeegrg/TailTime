const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
require('dotenv').config();

const app = express();

// Middleware
app.use(express.json()); // Allows us to receive JSON data
app.use(cors()); // Allows external connections

// Database Connection
mongoose.connect(process.env.MONGO_URI)
    .then(() => console.log('MongoDB Connected'))
    .catch(err => console.log('DB Connection Error:', err));


app.use('/api/auth', require('./routes/auth'));
app.use('/api/pets', require('./routes/pets'));
app.use('/api/events', require('./routes/events'));
app.use('/api/medical', require('./routes/medical'));
app.use('/api/user', require('./routes/user'));

// Basic Route
app.get('/', (req, res) => {
    res.send('TailTime Backend is Running!');
});

// Start Server
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));

const listEndpoints = require('express-list-endpoints'); // Import it

app.listen(PORT, () => {
    
    console.log("\nRegistered Routes:");
    console.table(listEndpoints(app)); 
});