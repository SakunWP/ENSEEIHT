package allumettes;

public class StrategieRapide implements Strategie {

    public int getPrise(Jeu jeu) {
        if (jeu.getNombreAllumettes() >= Jeu.PRISE_MAX) {
            return Jeu.PRISE_MAX;
        } else {
            return jeu.getNombreAllumettes();
        }
    }
}
