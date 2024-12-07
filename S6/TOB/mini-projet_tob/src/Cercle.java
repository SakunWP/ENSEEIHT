//import java.awt.*;
import java.awt.Color;
/**
 * Cette classe représente un cercle dans un plan 2D.
 * */
public class Cercle implements Mesurable2D {

    /**
     * rayon du cercle de type double.
     **/
    private double rayon;
    /**
     * Centre du cercle de type Point.
     **/
    private Point centre;
    /**
     * La couleur du cercle, de type Color.
     **/
    private Color couleur;
    /**
     * Constante pi.
     */
    public static final double PI = Math.PI;

    /**
     * Constructeur permettant de créer un cercle avec un centre et un rayon donné.
     * @param pt Le centre du cercle
     * @param rayon Le rayon du cercle
     * */
    public Cercle(Point pt, double rayon) {
        assert rayon > 0;
        assert pt != null;
        Point ctre = new Point(pt.getX(), pt.getY());
        this.rayon = rayon;
        this.centre = ctre;
        this.couleur = Color.blue;
    }

    /**
     * Constructeur permettant de créer un cercle avec deux points et une couleur donnée.
     * @param p1 Point d'extrémité 1
     * @param p2 Point d'extrémité 2
     * @param clr La couleur du cercle
     * */
    public Cercle(Point p1, Point p2, Color clr) {
        assert p1 != null;
        assert p2 != null;
        assert clr != null;
        assert (p1.getX() != p2.getX() || p1.getY() != p2.getY());
        this.rayon = p1.distance(p2) / 2;
        double cx = (p1.getX() + p2.getX()) / 2;
        double cy = (p1.getY() + p2.getY()) / 2;
        Point c = new Point(cx, cy);
        this.centre = c;
        this.couleur = clr;
    }

    /**
     * Constructeur permettant de créer un cercle avec deux points et une couleur donnée.
     * @param p1 Point d'extrémité 1
     * @param p2 Point d'extrémité 2
     * */
    public Cercle(Point p1, Point p2) {
        assert p1 != null;
        assert p2 != null;
        assert (p1.getX() != p2.getX() || p1.getY() != p2.getY());
        this.couleur = Color.blue;
        this.rayon = p1.distance(p2) / 2;
        double cx = (p1.getX() + p2.getX()) / 2;
        double cy = (p1.getY() + p2.getY()) / 2;
        Point c = new Point(cx, cy);
        this.centre = c;
    }

    /**
     * Fonction permettant de translater un cercle.
     * @param dx Declacement selon l'axe des absisses
     * @param dy Deplacenet selon l'axe des ordonnées
     * */
    public void translater(double dx, double dy) {
        this.centre.translater(dx, dy);
    }

    /**
     * Acces au centre.
     * @return Coordonnées du centre
     * */
    public Point getCentre() {
        Point copieCentre = new Point(this.centre.getX(), this.centre.getY());
        return copieCentre;
    }

    /**
     * Acces au rayon.
     * @return Rayon
     * */
    public double getRayon() {
        return this.rayon;
    }

    /**
     * Acces à la couleur.
     * @return Couleur
     * */
    public Color getCouleur() {
        return this.couleur;
    }

    /**
     * Acces au diamètre.
     * @return Diamètre
     * */
    public double getDiametre() {
        return 2 * getRayon();
    }

    /**
     * Permet de modifier le rayon du cercle.
     * @param r Le rayon
     * */
    public void setRayon(double r) {
        assert r > 0;
        this.rayon = r;
    }

    /**
     * Permet de modifier le diamètre du cercle.
     * @param d Le diametre
     * */
    public void setDiametre(double d) {
        assert d > 0;
        this.rayon = d / 2;
    }

    /**
     * Permet de vérifier si un point est dans le cercle.
     * @param a Le point à vérifier
     * @return true si le point A est dans le cercle, false sinon
     * */
    public boolean contient(Point a) {
        assert a != null;
        double d = this.centre.distance(a);
        return (d <= this.rayon);
    }

    /**
     * Calculer le perimètre.
     * @return Périmètre
     * */
    public double perimetre() {
        return 2 * PI * getRayon();
    }

    /**
     * Calculer l'aire.
     * @return Aire
     * */
    public double aire() {
        return PI * (getRayon() * getRayon());
    }

    /**
     * Modifier la couleur.
     * @param nc La nouvelle couleur
     * */
    public void setCouleur(Color nc) {
        assert nc != null;
        this.couleur = nc;
    }

    /**
     * Créer un cercle avec deux points et une couleur donnée.
     * @param pt1 Point d'extrémité 1
     * @param pt2 Point d'extrémité 2
     * @return Le nouveau cercle crée à partir des deux points
     * */
    public static Cercle creerCercle(Point pt1, Point pt2) {
        assert pt1 != null;
        assert pt2 != null;
        Cercle nc = new Cercle(pt1, pt1.distance(pt2));
        return nc;
    }

    /**
     * Fonction permetant d'afficher le cercle sous le format "Crayon@centre".
     * @return L'affichage du cercle sous format texte
     * */
    public String toString() {
        return "C" + this.rayon + "@" + this.centre.toString();
    }
}
