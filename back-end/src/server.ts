import 'dotenv/config'
import express from "express"
import cors from "cors"
import { routerContact } from "./routes/router-contact.js";
import { routerCall } from "./routes/router-call.js";

const app = express()

app.use(cors());
app.use(express.json());
app.use("/contacts", routerContact);
app.use("/calls", routerCall);

const PORT: number = 5000
app.listen(PORT, '0.0.0.0',() => console.log(`Servidor iniciado em <http://localhost>:${PORT}/`))