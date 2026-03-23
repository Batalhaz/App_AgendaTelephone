import { Router } from "express"
import { callController } from "../controller/call-controller.js"
 
export const routerCall = Router()

routerCall.get("/", callController.index)
routerCall.get("/contact/:id", callController.getCallBycontact)
routerCall.get("/detail/:id", callController.showCall)
routerCall.post("/", callController.newCall) 

routerCall.delete("/delete", callController.deleteAllCalls)
routerCall.delete("/:id", callController.deleteCall) 