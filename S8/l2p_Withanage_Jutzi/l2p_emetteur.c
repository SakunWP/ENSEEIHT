#include <linux/version.h>
#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/delay.h>
#include <linux/if_ether.h>
#include <linux/workqueue.h>
#include <linux/netdevice.h>
#include <linux/etherdevice.h>
#include <linux/skbuff.h>
#include <asm/byteorder.h>
#include <linux/parport.h>

MODULE_LICENSE("GPL");

union {
  struct {
#if defined(__LITTLE_ENDIAN)
    unsigned char lsb;
    unsigned char msb;
#elif defined (__BIG_ENDIAN)
    unsigned char msb;
    unsigned char lsb;
#else
#error "Par quel bout ?"
#endif
  } b;
  unsigned short h;
} longueur;

#define MAX_TIMEOUT 100
#define TIMEOUT_DELAY 10000
#define IS_BUSY(status) ((status & 0x80) == 0x80)


/* Ceci est la ligne 35 */

/* Une structure pour stocker les données associées à notre pilote */	
struct l2p_dev {
    struct pardevice *ppdev; /* Notre pilote est enregistré au port parallèle */
};
struct l2p_dev l2p_device;





void l2p_wakeup(void *data) {
}

int l2p_preempt(void *data) {
	return 0;
}

void l2p_irq(void *data) {
}

/* Ceci est la ligne 57 */
int emettre_octet(unsigned char octet, struct parport *pport) {
	/* les différents états de l'automate, cf sujet */
	enum sender_states_t {DEBUT_1, QUATRET_1, ACK_1, QUATRET_2, OK, N_OK};
	enum sender_states_t sender_state = DEBUT_1;
	int timeout = MAX_TIMEOUT;

	unsigned char status = 0;
	unsigned char quatret1 = octet & 0x0F;
	unsigned char quatret2 = (octet>>4) & 0x0F;
	unsigned char quatret1_D_4_1 = quatret1+0x10;
	unsigned char quatret2_D_4_1 = quatret2+0x10;

	while(sender_state != N_OK && sender_state != OK) {
		
		printk("Mode initial : on lit le status qui vaut : %x\n",status);

		switch(sender_state) {
			case DEBUT_1:
				status = pport->ops->read_status(pport);
				printk("On passe en mode DEBUT_1\n");
				if (!IS_BUSY(status) && timeout > 0) {
					timeout --;
					printk("Mode DEBUT_1 : on attend que le port soit busy\n");
					udelay(TIMEOUT_DELAY);
				} else if(timeout == 0) {
					sender_state = N_OK;
					printk("Mode DEBUT_1 : on passe en mode N_OK\n");
				} else {
					/* on écrit le premier quatret et on met D_4 à 0*/
					pport->ops->write_data(pport,quatret1);
					printk("Mode DEBUT_1 : on écrit le premier quatret\n");
					sender_state=QUATRET_1;
				}
				printk("Mode DEBUT_1 : on reverifie le switch\n");
				break;				
	
			case QUATRET_1:
				/* écrire le premier quatret et on met D_4 à 1 */				
				printk("écriture du premier quatret \n");
				pport->ops->write_data(pport,quatret1_D_4_1);
				timeout = MAX_TIMEOUT;
				sender_state = ACK_1;
				break;

			case ACK_1 :
				printk("en attente d'ACK \n"); 
				status = pport->ops->read_status(pport);
				/* On attend que le récepteur lise */
				if (IS_BUSY(status) && timeout > 0) {
					timeout --;
					udelay(TIMEOUT_DELAY);
				} else if (!IS_BUSY(status) && timeout > 0) {
					/* Le récepteur a lu et envoyé D_4 = 1 */
					sender_state = QUATRET_2;

					/* On envoie le signal D_4 = 1 */
					pport->ops->write_data(pport,quatret2_D_4_1);
				} else {
					/* Connexion perdue */
					sender_state = N_OK;
				}
				break;
					
			case QUATRET_2 :
				printk("écriture du second quatret \n");
				timeout = MAX_TIMEOUT;
				/* écrire le deuxième quatret */
				pport->ops->write_data(pport,quatret2);
				printk("succès de l'écriture, passage en mode OK \n");
				sender_state = OK;
				break;
			case OK : 
				printk("Emission realisee avec succes \n");
				break;
			case N_OK : 
				printk("Echec de l'emission : connexion perdue \n");
				break;
		}
	}
	return (sender_state == OK);
}


/* Initialisation d'un client du port parallèle, et émission de données. */
void l2p_attach(struct parport *pport) {
	/* 0. Données */
	unsigned char data=0x5;
	struct pardevice *ppdev;

	/* 1. On s'enregistre auprès du port */
	ppdev = parport_register_device(pport,"l2p",l2p_preempt,l2p_wakeup,l2p_irq,0,&l2p_device);
	printk("l2p: attach pour %s\n", pport->name);
	l2p_device.ppdev= ppdev;

	/* 2. On réclame le port. */
	if (ppdev) {
		parport_claim(ppdev);
	
		/* 3. On envoie des bits "0101" soit (0x5)". */
		emettre_octet('A', pport);
		//pport->ops->write_data(pport,data);
		printk("Message envoyé\n");
	}
}

/* Desenregistrement d'un client peripherique reseau */
void l2p_detach(struct parport *pport) {

	/* Si on a été enregistré, on peut faire les process de desenregistrement */
	if (l2p_device.ppdev) {
		
		/* 1. On libère le port. */
		parport_release(l2p_device.ppdev);
			
		/* 2. On se désenregistre */
		parport_unregister_device(l2p_device.ppdev);
	}
		

  printk("l2p: detach pour le port %s\n", pport->name);
}

/* Définition d'un pilote du port parallèle (voir p94 du document sur le port parallèle) */
static struct parport_driver l2p_ppdrv= {
  .name = "l2p",
  .attach = l2p_attach,
  .detach = l2p_detach
};


/* Lancement du module */
static int l2p_init(void) {
	/* 1. On s'enregistre auprès du driver en indiquant toutes les fonctions (présentes dans l2p_ppdrv) */
	if (parport_register_driver(&l2p_ppdrv) != 0){
		printk("12p: parport_register_drive failed\n");
		return -EIO;
	} 


    printk("Le module L2P est chargé\n");

    return 0;
}

/* Terminaison du module */
static void l2p_cleanup(void) {
	
	/* dernière étape, on desenregistre auprès du pilote */
	parport_unregister_driver(&l2p_ppdrv);

    printk("Le module L2P est déchargé\n");
}

module_init(l2p_init); /** lorsqu'on fait insmod linux exécute module_init */
module_exit(l2p_cleanup);
