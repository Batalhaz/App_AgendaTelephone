import { callModel } from "../models/call-model.js";
import { Request, Response } from "express";

export const callController = {
    index: async(req: Request, res: Response) =>{
        try {
            const calls = await callModel.showAllCall();
            res.status(200).json(calls);
        } catch (error) {
            res.status(400).json({error: "Erro ao buscar chamadas"});
        }
    },

    getCallBycontact: async(req: Request, res: Response) =>{
        try {
            const idContact = Number(req.params.id);
            if(isNaN(idContact)){
                return res.status(400).json({error: "ID de contato inválido"});
            }
            const contact = await callModel.getCallsByContact(idContact);
            res.status(200).json(contact);
        } catch (error) {
            res.status(400).json({error: "Erro ao buscar ligacao"});
        }
    },

    newCall: async(req: Request, res: Response) =>{
        const {idContact, duration} = req.body;

        if(idContact  == undefined || duration == undefined){
            return res.status(400).json({error: "idContact e duration são obrigatórios"});
        }

        try {
            const newCall = await callModel.createCall(Number(idContact), Number(duration));  
            res.status(201).json(newCall);  
        } catch (error) {
            res.status(400).json({error: "Erro ao registrar chamada"})
        }
    },

    showCall: async(req: Request, res: Response) =>{
        const id = Number(req.params.id);

        if(isNaN(Number(id))){
            return res.status(400).json({error: "ID de chamada inválido"});
        }

        try {
            const call = await callModel.showCallDetail(id);
            res.status(200).json(call);
        } catch (error) {
            res.status(400).json({error: "Erro ao buscar chamada"});
            
        }
    },

    deleteCall: async(req: Request, res: Response) =>{
        try {
            const id = Number(req.params.id)

            if(isNaN(id)){
                return res.status(400).json({error: "ID de chamada inválido"});
            }

            await callModel.deleteCall(id);
            res.status(200).json({message: "Chamada deletada com sucesso"});
        } catch (error) {
            res.status(400).json({error: "Erro ao deletar chamada"});
        }
    },

    deleteAllCalls: async(req: Request, res: Response) =>{
        try {
            await callModel.deleteAllCalls();
            res.status(204).send();
        } catch (error) {
            res.status(400).json({error: "Erro ao deletar chamadas"});
        }
    }
}