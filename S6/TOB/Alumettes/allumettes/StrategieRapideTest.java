package allumettes;
import org.junit.Test;
import static org.junit.Assert.*;

public class StrategieRapideTest {

    public final static double EPSILON = 0.001;

    private Jeu jeu;
    private Strategie strat;
    private Joueur joueur;
    private int allumRes;


    public void setUp() {
        jeu = new JeuProcurration(jeu);
        strat = new StrategieRapide();
        joueur = new Joueur("joueurRapide", strat);
        allumRes = jeu.getNombreAllumettes();
    }
    @Test
    public void testGetPrise1() {

        Jeu jeu = new JeuClassique();

        StrategieRapide strategie = new StrategieRapide();

        assertEquals(3, strategie.getPrise(jeu)); 
    }

    @Test
    public void testGetPrise2() throws CoupInvalideException {
        Jeu jeu = new JeuClassique(5);

        jeu.retirer(Jeu.PRISE_MAX);

        StrategieRapide strategie = new StrategieRapide();

        assertEquals(2, strategie.getPrise(jeu));
    }

    @Test
    public void testGetPrise3() {
        Jeu jeu = new JeuClassique(1);

        StrategieRapide strategie = new StrategieRapide();

        assertEquals(1, strategie.getPrise(jeu));
    }

}
