package allumettes;

public class JeuClassique implements Jeu {

    private int nbAllumettes;
    int allTotal = 13;


    public JeuClassique(int allumettes) {
        this.nbAllumettes = allumettes;
    }

    public JeuClassique() {
        this.nbAllumettes = allTotal;
    }


    @Override
    public int getNombreAllumettes() {
        return this.nbAllumettes;
    }

    public void retirer(int nbPrises) throws CoupInvalideException {
        if (nbPrises < 1) {
            throw new CoupInvalideException(nbPrises, "<1");
        } else if (this.nbAllumettes < nbPrises) {
            throw new CoupInvalideException(nbPrises, ">" + nbAllumettes);
        } else if (nbPrises > PRISE_MAX) {
            throw new CoupInvalideException(nbPrises, ">" + PRISE_MAX);
        } else {
            this.nbAllumettes = this.nbAllumettes - nbPrises;
        }
    }
}
