const dotenv = require('dotenv');
const mongodb = require("./mongodb");
const fs = require('fs');
const createCsvWriter = require('csv-writer').createObjectCsvWriter;

dotenv.config();

const {
    MONGO_DBNAME,
    MONGO_URI,
} = process.env;

async function exportIntoCSV() {
    const collName = "recipe"
    const csvFilePath = "data.csv"
    const aggPipeline = [
        {
            '$match': {
                'ingredients.unit': 5
            }
        }, {
            '$project': {
                'title': 1,
                'slug': 1,
                'status': 1,
                '_id': 1
            }
        }
    ];

    const data = await mongodb.aggregation(MONGO_URI, MONGO_DBNAME, collName, aggPipeline);

    // Define the CSV file path and headers
    const csvWriter = createCsvWriter({
        path: csvFilePath,
        header: [
            { id: '_id', title: 'Id' },
            { id: 'title', title: 'Title' },
            { id: 'slug', title: 'Slug' },
            { id: 'status', title: 'Status' },
        ],
    });

    csvWriter.writeRecords(data)
        .then(() => {
            console.log('CSV file has been written successfully');
        })
        .catch((error) => {
            console.error('Error writing CSV file:', error);
        });
}

async function main() {
    await exportIntoCSV();
}

main();