package editeur.commande;

import editeur.Ligne;
import util.Console;

public class CommandeRevenirZero extends CommandeLigne{
    public CommandeRevenirZero(Ligne l) {
        super(l);
    }

    public void executer(){
        ligne.raz();
    }

    @Override
    public boolean estExecutable() {
        return(ligne.getLongueur()>0);
    }
}
