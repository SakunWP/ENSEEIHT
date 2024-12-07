package allumettes;

public class Arbitre {
    private Joueur joueur1;
    private Joueur joueur2;
    private boolean confiant;

    public Arbitre(Joueur j1, Joueur j2) {
        this.joueur1 = j1;
        this.joueur2 = j2;
        this.confiant = false;
    }

    public void setConfiant() {
        this.confiant = true;
    }

    private void demanderPrise(Jeu jeu, Jeu jeuproc, Joueur j) {
        boolean entierOK = false;
        boolean stop = false;
        int prise = 0;
        while (!entierOK) {
            try {
                System.out.println("Allumettes restantes : " + jeu.getNombreAllumettes());
                prise = j.getPrise(jeuproc);
                //break;
                if (prise > 1) {
                    if (prise > Jeu.PRISE_MAX) {
                        System.out.println(j.getNom() + " prend "
                                + prise + " allumettes.");
                    } else {
                        System.out.println(j.getNom() + " prend "
                                + prise + " allumettes.");
                        System.out.println();
                        //break;
                    }
                } else {
                    System.out.println(j.getNom() + " prend "
                            + prise + " allumette.");
                    System.out.println();
                    //break;
                }
                jeu.retirer(prise);
                entierOK = true;
            } catch (CoupInvalideException e) {
                System.out.println("Impossible ! Nombre invalide : "
                        + e.getCoup() + " (" + e.getProbleme() + ")");
                //System.out.println();
            } catch (OperationInterditeException e) {
                System.out.println("Abandon de la partie car "
                        + j.getNom() + " triche !");
                //break;
                System.exit(0);      //pas le choix j'arrivais pas à faire autrement
            }
        }
    }

    private void appelDemanderPrise(Jeu jeu, Joueur j) {
        if (this.confiant) {
            demanderPrise(jeu, jeu, j);
        } else {
            demanderPrise(jeu, new JeuProcurration(jeu), j);
        }
    }

    private void affichFin(Joueur perdant, Joueur gagnant) {
        System.out.println(perdant.getNom() + " perd !");
        System.out.println(gagnant.getNom() + " gagne !");
    }

    public void arbitrer(Jeu jeu) {
        boolean j1Perd = false;
        while (jeu.getNombreAllumettes() != 0) {
            //try {
            appelDemanderPrise(jeu, joueur1);
            if (jeu.getNombreAllumettes() != 0) {
                appelDemanderPrise(jeu, joueur2);
            } else {
                affichFin(joueur1, joueur2);
                j1Perd = true;
            }
            //} catch (OperationInterditeException e) {
            //throw new OperationInterditeException(e.getMessage());
            //}
        }
        if (!j1Perd) {
            affichFin(joueur2, joueur1);
        }
    }


}
