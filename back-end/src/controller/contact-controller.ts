import { contactModel } from "../models/contact-model.js";
import { Request, Response } from "express";

export const contactController = {
    allContacts: async(req: Request, res: Response) => {
        try {
            res.status(200).json(await contactModel.findAllContacts());
        } catch (error) {
            res.status(400).json({error: "Erro ao buscar contatos"  });
            console.log(error)
        }
    },

    contactsFavorites: async(req: Request, res: Response) => {
        try {
            res.status(200).json(await contactModel.findFavoriteContacts())
        } catch (error) {
            res.status(400).json({error: "Erro ao buscar contatos favoritos"});
        }
    },

    contactsByName: async(req: Request, res: Response) => {
        try {
            const { name } = req.query;
            if(!name){
                return res.status(400).json({error: "Nome é obrigatório para busca"});
            }
            res.status(200).json(await contactModel.searchContactsByName(String(name)));
        } catch (error) {
            res.status(400).json({error: "Erro ao buscar contatos por nome"});
        }
    },

    contactById: async(req: Request, res: Response) => {
        try {
            const id = Number(req.params.id);
            if(isNaN(id)){
                return res.status(400).json({error: "ID de contato inválido"});
            }
            res.status(200).json(await contactModel.findContactById(id));
        } catch (error) {
            res.status(400).json({error: "Erro ao buscar contato por ID"});
        }
    },

    newContact: async(req: Request, res: Response) => {
        try {
            const {name, photoUrl, phones, categoryId, isFavorite} = req.body;
            if(!name || name.trim() === ""){
                return res.status(400).json({error: "Nome é obrigatório para criar contato"});
            }
            const contactData = {
                name, 
                photoUrl, 
                phones, 
                categoryId: Number(categoryId), 
                isFavorite: Boolean(isFavorite)
            }
            const result = await contactModel.createContact(contactData);
            res.status(201).json(result);
        } catch (error) {
            res.status(400).json({error: "Erro ao criar novo contato"});
        }
    },

    toggleFavorite: async(req: Request, res: Response) => {
        try {
            const idContact = Number(req.params.id);
            if(isNaN(idContact)){
                return res.status(400).json({error: "ID de contato inválido"});
            }
            res.status(200).json(await contactModel.toggleFavorite(idContact));
        } catch (error) {
            res.status(400).json({error: "Erro ao atualizar favorito"});
        }
    },

    updateCategory: async(req: Request, res: Response) => {
        try {
            const id = Number(req.params.id);
            const {category} = req.body;
            if(isNaN(id) || category === undefined || category.trim() === ""){
                return res.status(400).json({error: "ID de contato e categoria são obrigatórios para atualizar"});
            }
            res.status(200).json(await contactModel.updateContactCategory(id, category));
        } catch (error) {
            res.status(400).json({error: "Erro ao atualizar categoria"});
        }
    },

    updateContact: async(req: Request, res: Response) => {
        try {
            const id = Number(req.params.id);
            const {name, photoUrl, phones, categoryId, isFavorite} = req.body;
            if(isNaN(id)){
                return res.status(400).json({error: "ID inválido"});
            }
            res.status(200).json(await contactModel.updateContact(id, name, photoUrl, phones, categoryId, isFavorite));
        } catch (error) {
            res.status(400).json({error: "Erro ao atualizar contato"});
        }
    },

    deleteContact: async(req: Request, res: Response) => {
            try {
                const id = Number(req.params.id);   
                if(isNaN(id)){
                    return res.status(400).json({error: "ID de contato inválido"});
                }
                await contactModel.deleteContact(id);
                res.status(204).send();
            } catch (error) {
                res.status(400).json({error: "Erro ao deletar contato"});
            }
    }
}