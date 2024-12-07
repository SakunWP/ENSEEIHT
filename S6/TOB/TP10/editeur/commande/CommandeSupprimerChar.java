package editeur.commande;
import editeur.Ligne;
import util.Console;
public class CommandeSupprimerChar extends CommandeLigne{
    public CommandeSupprimerChar(Ligne l){
        super(l);
    }

    public void executer(){
        ligne.supprimer();
    }

    @Override
    public boolean estExecutable() {
        return ligne.getLongueur()>0;
    }
}
