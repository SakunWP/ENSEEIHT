package allumettes;

public class StrategieTriche implements Strategie {

    @Override
    public int getPrise(Jeu jeu) {
        try {
            System.out.println("[Je triche...]");
            int prise = jeu.getNombreAllumettes() - 2;
            while (prise >= 0) {
                if (prise >= Jeu.PRISE_MAX) {
                    jeu.retirer(Jeu.PRISE_MAX);
                } else {
                    jeu.retirer(prise);
                }
                prise = prise - Jeu.PRISE_MAX;
            }

            System.out.println("[Allumettes restantes : "
                    + jeu.getNombreAllumettes() + "]");
        } catch (CoupInvalideException e) {
            System.out.println("[Plus assez d'allumettes pour tricher]");
        }
        return 1;
    }
}
