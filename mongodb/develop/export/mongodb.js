const {MongoClient} = require("mongodb");

async function aggregation(mongoUri, dbName, coll, aggPipeline) {
    const client = new MongoClient(mongoUri);
    try {
        await client.connect();
        const db = client.db(dbName);
        const collection = db.collection(coll);
        const cursor = await collection.aggregate(aggPipeline);
        const result = await cursor.toArray();
        return result;
    } catch (error) {
        console.log(error)
    } finally {
        await client.close();
    }
}

module.exports = {aggregation}