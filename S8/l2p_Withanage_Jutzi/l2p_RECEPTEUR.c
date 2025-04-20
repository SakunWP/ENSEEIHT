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

#define MAX_TIMEOUT 100
#define ISBUSY(status) ((status & 0x80) == 0x80)
#define TIMEOUT_DELAY 10000

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

/* Structure pour stocker les données du pilote */
struct l2p_dev {
    struct pardevice *ppdev;
    struct parport *pport;
};

struct l2p_dev l2p_device;

void l2p_wakeup(void *data) {}

int l2p_preempt(void *data) {
    return 0;
}

int recevoir_octet(unsigned char *octet, struct parport *pport) {
    unsigned char status = 0;
    enum recever_states_t { DEBUT_1, QUATRET_1, ACK_1, QUATRET_2, OK, N_OK };
    enum recever_states_t recever_state = DEBUT_1;

    int timeout = MAX_TIMEOUT;

    while (recever_state != N_OK && recever_state != OK) {
        switch (recever_state) {
            case DEBUT_1:
                pport->ops->write_data(pport, 0x0);
                printk("l2p: emettre octet statut dans debut %d\n", recever_state);
                printk("l2p: timeout %d\n", timeout);
                recever_state = QUATRET_1;
                break;

            case QUATRET_1:
                status = pport->ops->read_status(pport);
                if (timeout == 0) {
                    recever_state = N_OK;
                    printk("l2p: recevoir quatret 1 statut %x\n", status);
                    printk("l2p: timeout %d\n", timeout);
                } else if (ISBUSY(status) && timeout > 0) {
                    timeout--;
                    printk("l2p: recevoir quatret 1 statut %x\n", status);
                    udelay(TIMEOUT_DELAY);
                } else {
                    *octet = (status >> 3) & 0xf;
                    recever_state = ACK_1;
                    printk("l2p: quatret1 = %x\n", *octet);
                }
                break;

            case ACK_1:
                pport->ops->write_data(pport, 0x10);
                timeout = MAX_TIMEOUT;
                recever_state = QUATRET_2;
                printk("l2p: recevoir octet statut %x\n", status);
                printk("l2p: timeout %d\n", timeout);
                break;

            case QUATRET_2:
                status = pport->ops->read_status(pport);
                if (!ISBUSY(status) && timeout > 0) {
                    timeout--;
                    udelay(TIMEOUT_DELAY);
                } else if (ISBUSY(status)) {
                    recever_state = OK;
                } else {
                    recever_state = N_OK;
                    printk("l2p: recevoir octet statut %x\n", status);
                    printk("l2p: timeout %d\n", timeout);
                }
                break;

            default:
                break;
        }
    }

    if (recever_state == OK) {
        *octet = *octet | ((status << 1) & 0xf0);
    } else {
        return -1;
    }

    return 0;
}

void l2p_irq(void *data) {
    /*unsigned char octet;
    struct l2p_dev *dev = (struct l2p_dev *) data;
    struct parport *pport = dev->pport;

    disable_irq(pport->irq);
    pport->ops->write_data(pport, 0x10);

    if (recevoir_octet(&octet, pport) == -1) {
        printk("pb de transmission (petit flop et un peu cringe)");
    } else {
        printk("ok on a reçu %x", octet);
    }

    enable_irq(pport->irq);*/

// AUTRE TENTATIF DESESPÉRÉ qui ne marche pas non plus
    struct parport *pport;
	 unsigned char status;
	 pport=l2p_device.pport;
	 disable_irq(pport);
	 status = pport->ops->read_status(pport);
	 if (ISBUSY(status)){
		 struct pardevice *ppdev;
		    //unsigned char octet_recu;
		    unsigned char octet_recu;
		    printk("l2p: on attache %s\n", pport->name);
		    
		    //Enregistrement du client du port parallèle
		    ppdev= parport_register_device(
			pport, "12p", l2p_preempt, l2p_wakeup, l2p_irq, 0, &l2p_device);

		    if(ppdev == NULL) {
		       printk("l2p: fail (petit flop)\n");
		    }

		    // Stocker les données associées
		    l2p_device.ppdev = ppdev; 

		   // Revendiquer le port parallèle
		   if (parport_claim(ppdev)) {
		       printk("l2p: parport_claim failed (petit flop et un peu cringe) \n"); 
		   }
			
		   pport->ops->enable_irq(pport);
		 
		   printk("l2p : Client enregistré et port pris\n");
		    pport->ops->write_data(pport,0x0);
		   if (recevoir_octet(&octet_recu, pport) == 1) {
		       printk("l2p : Octet recu avec succès : %x\n", octet_recu);
		   }
	}
	   	
	   printk("l2p: Interruption reçue\n");
}

void l2p_attach(struct parport *pport) {
    struct pardevice *ppdev;
    unsigned char status;
    
    ppdev = parport_register_device(pport, "l2p", l2p_preempt, l2p_wakeup, l2p_irq, 0, &l2p_device);
    printk("l2p: attach pour %s\n", pport->name);
    l2p_device.ppdev = ppdev;

    if (ppdev) {
        parport_claim(l2p_device.ppdev);
        recevoir_octet(&status, pport);
        printk("on lit %x\n", status);
    }
}

void l2p_detach(struct parport *pport) {
    if (l2p_device.ppdev) {
        printk("je lis pas");
        parport_release(l2p_device.ppdev);
        parport_unregister_device(l2p_device.ppdev);
    }
    printk("l2p: detach pour le port %s\n", pport->name);
}

static struct parport_driver l2p_ppdrv = {
    .name = "l2p",
    .attach = l2p_attach,
    .detach = l2p_detach
};

static int l2p_init(void) {
    if (parport_register_driver(&l2p_ppdrv) != 0) {
        printk("l2p: parport_register_driver failed\n");
        return -EIO;
    }

    printk("Le module L2P est chargé\n");
    return 0;
}

static void l2p_cleanup(void) {
    parport_unregister_driver(&l2p_ppdrv);
    printk("Le module L2P est déchargé\n");
}

module_init(l2p_init);
module_exit(l2p_cleanup);
