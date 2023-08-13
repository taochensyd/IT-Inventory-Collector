const express = require('express');
const bodyParser = require('body-parser');
const ExcelJS = require('exceljs');
const fs = require('fs');
const path = require('path');

const app = express();
const PORT = 9000;

//Routes
const pcInfoRoute = require('./routes/pcinfo');

app.use(bodyParser.json());

// Use the route
app.use('/api/v1/pcinfo', pcInfoRoute);

app.listen(PORT, () => {
    console.log(`Server is running on http://localhost:${PORT}`);
});
