import org.junit.Before;
import org.junit.Test;

import java.awt.*;

import static org.junit.Assert.assertEquals;

public class CercleTest {
    public final static double EPSILON = 0.001;

    // Les points du sujet
    private Point A, B, C, D;

    // Les cercles du sujet
    private Cercle C1, C2, C3;

    @Before
    public void setUp() {
        // Construire les points
        A = new Point(0, 1);
        B = new Point(1, 0);
        C = new Point(4, 1);
        D= new Point(8, 4);
    }

    @Test public void testerE12(){
        C1 = new Cercle(A,B);
        assertEquals("centre pas au bon endroit", 0.5, C1.getCentre().getX(), EPSILON);
        assertEquals("centre pas au bon endroit", 0.5, C1.getCentre().getY(), EPSILON);
        assertEquals("pas le bon rayon", Math.sqrt(2)/2, C1.getRayon(), EPSILON);
        assertEquals("pas le bon diamètre", Math.sqrt(2), C1.getDiametre(), EPSILON);
        assertEquals("cercle n'est pas de bon couleur", Color.blue, C1.getCouleur());
    }

    @Test public void testerE13(){
        C2= new Cercle (C,D,Color.red);
        assertEquals("centre pas au bon endroit", 6, C2.getCentre().getX(), EPSILON);
        assertEquals("centre pas au bon endroit", 2.5, C2.getCentre().getY(), EPSILON);
        assertEquals("pas le bon rayon", 2.5, C2.getRayon(), EPSILON);
        assertEquals("pas le bon diamètre", 5, C2.getDiametre(), EPSILON);
        assertEquals("cercle n'est pas de bon couleur", Color.red, C2.getCouleur());
    }

    @Test public void testerE14(){
        C3= Cercle.creerCercle(C,D);
        assertEquals("centre pas au bon endroit", 4, C3.getCentre().getX(), EPSILON);
        assertEquals("centre pas au bon endroit", 1, C3.getCentre().getY(), EPSILON);
        assertEquals("pas le bon rayon", 5, C3.getRayon(), EPSILON);
        assertEquals("pas le bon diamètre", 10, C3.getDiametre(), EPSILON);
        assertEquals("cercle n'est pas de bon couleur", Color.blue, C3.getCouleur());
    }
}
