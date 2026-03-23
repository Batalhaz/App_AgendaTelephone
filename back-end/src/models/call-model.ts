import prisma from "../database/index.js";

export const callModel = {
    showAllCall: async() =>{
        return await prisma.call.findMany({
            select: {
                id: true,
                startTime: true,
                duration: true,
                isLost: true,
                contact: {
                    select: {                        
                        name: true,
                        photoUrl: true
                    }
                }
            },
            orderBy:{
                duration: 'asc'
            }
        });
    },

    getCallsByContact: async(idContact: number) => {
        return await prisma.call.findMany({
            where: {
                contactId: idContact
            },
            select:{
                id: true,
                startTime: true,
                duration: true,
                contact: {
                    select: {
                        name: true,
                    }
                }
            },
            orderBy:{ 
                startTime: 'desc'
            }
        });
    },
   
    createCall: async(idContact: number, duration: number) => {
        return await prisma.call.create({
            data:{
                contactId: idContact,
                duration: duration
            },
            include: {
                contact: true
            }
        });

    },
   
    showCallDetail: async(id: number) => {
        return await prisma.call.findUnique({
            where: { id },
            include: {
                contact: true
            }
        });
    },
   
    deleteCall: async(id:number) => {
        return await prisma.call.delete({
            where: { id }
        });
    },

    deleteAllCalls: async() => {
        return await prisma.call.deleteMany();
    }
}



