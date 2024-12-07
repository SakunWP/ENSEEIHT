package allumettes;

public class JeuProcurration implements Jeu {

    private Jeu jeu;

    public JeuProcurration(Jeu game) {
        this.jeu = game;
    }
    @Override
    public int getNombreAllumettes() {
        return this.jeu.getNombreAllumettes();
    }

    @Override
    public void retirer(int nbPrises) throws CoupInvalideException {
        throw new OperationInterditeException("L'operation est interdite");
    }
}
