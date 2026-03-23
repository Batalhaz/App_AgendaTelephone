import prisma from "../database/index.js";

export const contactModel = {
    findAllContacts: async() => {
        return await prisma.contact.findMany({
            select: {
                id: true,
                name: true,
                photoUrl: true,
                phones: {
                    select: {
                        id: true,
                        number: true,
                        label: true
                    }
                },
                category:{
                    select: {
                        label: true
                    }
                }
            },
            orderBy:{
                name: 'asc'
            }
        });
    },

    findFavoriteContacts: async() => {
        return await prisma.contact.findMany({
            where: {
                isFavorite: true
            },
            select:{
                id: true,
                name: true,
                photoUrl:true,
                category:{
                    select:{
                        label: true
                    }
                }
            },
            orderBy:{
                name: 'asc'
            }
        })
    },

    findContactById: async(id: number) => {
        return await prisma.contact.findUnique({
            where: {
                id: id
            },
            select:{
                id: true,
                name: true,
                photoUrl: true,
                isFavorite: true,
                category: true,
                phones: {
                    select:{
                        id: true,
                        number: true,
                        label: true
                    }
                }
            }
        });
    },
    
    searchContactsByName: async(name: string) => {
        return await prisma.contact.findMany({
            where:{
                name:{
                    contains: name,
                    mode: 'insensitive'
                }
            },
            select:{
                id: true,
                name: true,
                photoUrl: true
            }
        })
    },
    
    createContact: async(data: any) => {
        const {name, photoUrl, phones, categoryId, isFavorite} = data;
        return await prisma.contact.create({
            data:{
                name: name,
                photoUrl: photoUrl ?? "",
                isFavorite: isFavorite,
                category:{
                    connect:{ id: categoryId }
                },
                phones:{
                    create: phones.map((p: { number: number; label: string; })=> ({
                        number: String(p.number),
                        label: p.label
                    }))
                }
            },
            include:{
                phones:true,
                category: true
            }
        });
    },
    
    toggleFavorite: async(id: number) => {
        const contact = await prisma.contact.findUnique({
            where:{
                id: id
            },
            select:{
                isFavorite: true
            }
        });

        if(!contact){
            throw new Error("Contato não encontrado");
        }

        return await prisma.contact.update({
            where:{
                id: id
            },
            data:{
                isFavorite: !contact.isFavorite
            }
        })
    },

    updateContactCategory: async(id: number, category: string) => {
        return await prisma.contact.update({
            where:{
                id: id
            },
            data:{
                category:{
                    connect: {label: category}
                }
            }
        })
    },

    updateContact: async (id: number, name: string, photoUrl: string, phones: any, categoryId: number, isFavorite: boolean) => {
        return await prisma.contact.update({
            where: { id },
            data: {
                name: name,
                photoUrl: photoUrl ?? "",
                isFavorite: isFavorite,
                category: {connect:{ id: categoryId }
                },
                phones:{
                    deleteMany: {},
                    create: phones.map((p: any) => ({
                        number: String(p.number),
                        label: p.label
                    }))
                }
            },
            include: {
                phones: true,
                category: true
            }
        });
    },

    deleteContact: async(id: number) => {   
        return await prisma.contact.delete({
            where:{
                id: id
            }
        })
    }
}