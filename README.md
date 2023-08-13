# IT-Inventory-Collector

## Overview

`IT-Inventory-Collector` is a comprehensive solution designed to facilitate automated hardware information gathering across various computing environments. Initially tailored for Windows systems using PowerShell, the roadmap includes extending its capabilities to Linux systems in the future.

## Features

- **Cross-platform Data Collection**: While the current version harnesses the power of PowerShell scripts for Windows environments, future iterations aim to cater to Linux systems as well.

- **Robust Backend Management**: Built on Node.js with the Express.js framework, the backend efficiently processes incoming data through RESTful API endpoints. This data can then be stored, manipulated, or used as needed.

- **Scalability & Flexibility**: The modular design ensures that adding new features or integrating with other systems remains straightforward, catering to growing or evolving IT infrastructure needs.

## Getting Started

### Prerequisites

- [Node.js](https://nodejs.org/) and npm installed on your machine.
- Basic knowledge of JavaScript, Express.js, and PowerShell scripting.

### Installation & Setup

1. **Clone the Repository**

    ```bash
    git clone https://github.com/taochensyd/IT-Inventory-Collector.git
    cd IT-Inventory-Collector
    ```

2. **Install Dependencies**

    ```bash
    npm install
    ```

3. **Run the Backend Server**

    ```bash
    npm start
    ```

   The server will start by default on port 3000 (unless specified otherwise).

4. **Client-Side Script**

   Execute the PowerShell script on client machines to collect hardware information and send the data to the backend.

## Usage

- Initiate the PowerShell script on any Windows-based machine for data collection.
  
- The script then sends a POST request with the compiled data to the backend.
  
- The backend can be configured to save this data to databases, files, or other storage mechanisms as per the requirement.

## Future Directions

- **Linux Support**: Plans are underway to introduce a script tailored for Linux environments, enabling data collection across heterogeneous IT landscapes.

## Contribution

Contributions, suggestions, and feedback are always welcome. Feel free to fork this repository, make your adjustments, and submit pull requests. For significant changes, kindly open an issue first to discuss the proposed modifications.

## License

This project is open-source and available under the [MIT License](LICENSE).
