import { Router } from "express"
import { contactController } from "../controller/contact-controller.js"

export const routerContact = Router()
 
routerContact.get("/", contactController.allContacts)
routerContact.get("/favorites", contactController.contactsFavorites)
routerContact.get("/search", contactController.contactsByName)

routerContact.get("/:id", contactController.contactById)
routerContact.post("/", contactController.newContact) 

routerContact.patch("/:id/favorite", contactController.toggleFavorite)
routerContact.put("/:id", contactController.updateContact)

routerContact.delete("/:id", contactController.deleteContact)