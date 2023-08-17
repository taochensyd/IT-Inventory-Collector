const express = require('express');
const router = express.Router();
const ExcelJS = require('exceljs');
const fs = require('fs');
const path = require('path');

router.post('/', async (req, res) => {
    const data = req.body;

    // Get local date and time
    const currentDate = new Date().toLocaleDateString();
    const currentTime = new Date().toLocaleTimeString();

    const workbook = new ExcelJS.Workbook();
    const folderPath = 'C:\\data';
    const filePath = path.join(folderPath, 'pc_info.xlsx');
    let currentId = 1;  // start with default ID

    // Check if the folder path exists and create it if it does not
    if (!fs.existsSync(folderPath)) {
        fs.mkdirSync(folderPath);
    }

    // Check if the Excel file exists
    if (fs.existsSync(filePath)) {
        await workbook.xlsx.readFile(filePath);
        const mainSheet = workbook.getWorksheet('Main');
        if (mainSheet) {
            const lastRow = mainSheet.lastRow;
            if (lastRow && lastRow.getCell(1).value) {
                currentId = lastRow.getCell(1).value + 1;
            }
        }
    } else {
        const mainSheet = workbook.addWorksheet('Main');
        mainSheet.addRow(['ID', 'Date', 'Time', 'PC Name', 'Logged In User', 'CPU Name', 'Cores', 'Frequency (GHz)', 'Threads', 'DIMM Slots Used', 'RAM Size (GB)', 'RAM Frequency (MHz)', 'Drive Letter', 'Used Size (GB)', 'Total Size (GB)', 'Disk Type', 'IP Address']);
        
        const cpuSheet = workbook.addWorksheet('CPU');
        cpuSheet.addRow(['ID', 'CPU Name', 'Cores', 'Frequency (GHz)', 'Threads']);

        const ramSheet = workbook.addWorksheet('RAM');
        ramSheet.addRow(['ID', 'DIMM Slots Used', 'Size (GB)', 'Frequency (MHz)']);

        const diskSheet = workbook.addWorksheet('Disk');
        diskSheet.addRow(['ID', 'Drive Letter', 'Used Size (GB)', 'Total Size (GB)', 'Disk Type']);

        const networkSheet = workbook.addWorksheet('Network');
        networkSheet.addRow(['ID', 'IP Address']);
    }

    const mainSheet = workbook.getWorksheet('Main');
    const cDrive = data.disks.find(d => d.driveLetter === 'C:');
    mainSheet.addRow([
        currentId,
        currentDate,
        currentTime,
        data.pcName || 'N/A',
        data.loggedInUser,
        data.cpuName.trim(),
        data.cpuCores,
        data.cpuFrequencyGHz,
        data.cpuThreads,
        data.dimmSlotsUsed,
        data.ramSizeGB,
        data.ramFrequencyMHz,
        cDrive ? cDrive.driveLetter : 'N/A',
        cDrive ? cDrive.usedSizeGB : 'N/A',
        cDrive ? cDrive.totalSizeGB : 'N/A',
        cDrive ? cDrive.diskType : 'N/A',
        data.ipAddress || 'N/A'
    ]);

    const cpuSheet = workbook.getWorksheet('CPU');
    cpuSheet.addRow([currentId, data.cpuName.trim(), data.cpuCores, data.cpuFrequencyGHz, data.cpuThreads]);

    const ramSheet = workbook.getWorksheet('RAM');
    ramSheet.addRow([currentId, data.dimmSlotsUsed, data.ramSizeGB, data.ramFrequencyMHz]);

    const diskSheet = workbook.getWorksheet('Disk');
    for (let disk of data.disks) {
        diskSheet.addRow([currentId, disk.driveLetter, disk.usedSizeGB, disk.totalSizeGB, disk.diskType]);
    }

    const networkSheet = workbook.getWorksheet('Network');
    networkSheet.addRow([currentId, data.ipAddress || 'N/A']);

    await workbook.xlsx.writeFile(filePath);

    res.status(200).send(`Data processed and Excel file updated/created successfully in ${folderPath}`);
});

module.exports = router;
