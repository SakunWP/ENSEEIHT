package allumettes;

public class StrategieExperte implements Strategie {

    public int getPrise(Jeu jeu) {
        int nbAl = jeu.getNombreAllumettes();
        int prise;
        int calculModulo = (nbAl - 1) % (Jeu.PRISE_MAX + 1);
        if (calculModulo != 0) {
            prise = (nbAl - 1) % (Jeu.PRISE_MAX + 1);
        } else if (nbAl == 1) {
            prise = 1;
        } else {
            prise = Jeu.PRISE_MAX;
        }
        return prise;
    }
}
