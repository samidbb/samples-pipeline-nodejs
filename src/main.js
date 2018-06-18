const express = require("express");
const app = express();

app.get("/", (req, res) => {
    res.send("hello world from nodejs");
});

app.listen(3000, () => {
    console.log("Node express server listening on port 5000");
});