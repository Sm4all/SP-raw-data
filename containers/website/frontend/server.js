const express = require("express");
const mongoose = require("mongoose");
const bcrypt = require("bcrypt");
const session = require("express-session");
const bodyParser = require("body-parser");

const app = express();
const PORT = 3000;

const mongoURI = `mongodb://${process.env.DB_HOST || "localhost"}:27017/${process.env.DB_NAME || "auth_db"}`;
mongoose.connect(mongoURI, { useNewUrlParser: true, useUnifiedTopology: true })
    .then(() => console.log("Connected to MongoDB"))
    .catch(err => console.error("MongoDB connection error:", err));

const userSchema = new mongoose.Schema({
    username: { type: String, unique: true, required: true },
    password: { type: String, required: true }
});

const User = mongoose.model("User", userSchema);

app.use(bodyParser.urlencoded({ extended: false }));
app.use(session({ secret: "secret", resave: false, saveUninitialized: true }));
app.set("view engine", "ejs");

app.get("/", (req, res) => {
    res.render("login", { error: "" });
});

app.post("/login", async (req, res) => {
    const { username, password } = req.body;
    try {
        const user = await User.findOne({ username });
        if (user && await bcrypt.compare(password, user.password)) {
            req.session.user = username;
            res.redirect("/home");
        } else {
            res.render("login", { error: "Invalid credentials" });
        }
    } catch (error) {
        console.error(error);
        res.render("login", { error: "Something went wrong" });
    }
});

app.post("/signup", async (req, res) => {
    const { username, password } = req.body;
    try {
        const hashedPassword = await bcrypt.hash(password, 10);
        await User.create({ username, password: hashedPassword });
        res.redirect("/");
    } catch (error) {
        res.render("login", { error: "User already exists or error occurred" });
    }
});

app.get("/home", (req, res) => {
    if (!req.session.user) return res.redirect("/");
    res.render("home", { user: req.session.user, date: new Date().toLocaleString() });
});

app.get("/logout", (req, res) => {
    req.session.destroy(() => res.redirect("/"));
});

app.listen(PORT, () => console.log(`Server running at http://localhost:${PORT}`));
