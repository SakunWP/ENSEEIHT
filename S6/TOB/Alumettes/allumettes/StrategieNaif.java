package allumettes;
import java.util.Random;

public class StrategieNaif implements Strategie {

    public int getPrise(Jeu jeu) {
        Random random = new Random();
        return random.nextInt(Jeu.PRISE_MAX) + 1;
    }
}
