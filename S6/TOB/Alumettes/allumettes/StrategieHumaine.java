package allumettes;
import java.util.Scanner;

public class StrategieHumaine implements Strategie {

    private static Scanner user = new Scanner(System.in);
    private String nom;
    public StrategieHumaine(String vnom) {
        this.nom = vnom;
    }

    public int getPrise(Jeu jeu) {
        boolean entierOK = false;
        int prise = 0;
        //System.out.println(this.nom + " combien d'allumettes ?");
        while (!entierOK) {
            try {
                System.out.print(this.nom + ", combien d'allumettes ? ");
                //System.out.println();
                String nextPrise = user.nextLine();
                if (nextPrise.equals("triche")) {
                    if (jeu.getNombreAllumettes() > 1) {
                        jeu.retirer(1);
                        System.out.println("[Une allumette en moins, plus que "
                                + jeu.getNombreAllumettes() + ". Chut !]");
                    }
                } else {
                    //System.out.println(this.nom + " combien d'allumettes ?");
                    prise = Integer.parseInt(nextPrise);
                    entierOK = true;
                }
            } catch (NumberFormatException e) {
                System.out.println("Vous devez donner un entier.");
            } catch (CoupInvalideException e) {
                System.out.println("[Plus assez d'allumettes pour tricher]");
            }
        }
        return prise;
    }
}
