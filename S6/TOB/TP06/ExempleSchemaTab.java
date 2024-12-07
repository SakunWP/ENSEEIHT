import afficheur.Ecran;
import afficheur.Afficheur;
import java.util.ArrayList;

/** Construire le schéma proposé dans le sujet de TP avec des points,
  * des points nommés
  * et des segments.
  *
  * @author	Xavier Crégut
  * @version	$Revision: 1.7 $
  */
public class ExempleSchemaTab {

	/** Construire le schéma et le manipuler.
	  * Le schéma est affiché.
	  * Ensuite, il est translaté et affiché de nouveau.
	  * @param args les arguments de la ligne de commande
	  */
	public static void main(String[] args)
	{
		// Créer les trois segments
		Point p1 = new PointNomme(3, 2, "A");
		Point p2 = new PointNomme(6, 9, "S");
		Point p3 = new Point(11, 4);
		Segment s12 = new Segment(p1, p2);
		Segment s23 = new Segment(p2, p3);
		Segment s31 = new Segment(p3, p1);

		// Créer le barycentre
		double sx = p1.getX() + p2.getX() + p3.getX();
		double sy = p1.getY() + p2.getY() + p3.getY();
		Point barycentre = new PointNomme(sx / 3, sy / 3, "C");

		// Définir le schéma (vide)
		//ElemSchema schema[] = new ElemSchema[10];	// le schéma
		ArrayList<ElemSchema> schema= new ArrayList<ElemSchema>();
			// 10 : capacité suffisante ici, non contrôlée dans la suite.
		int nb = 0;		// Le nombre d'éléments dans le schéma

		// Peupler le schéma
		//schema[nb++] = s12;
		schema.add(s12);
		//schema[nb++] = s23;
		schema.add(s23);
		//schema[nb++] = s31;
		schema.add(s31);
		//schema[nb++] = barycentre;
		schema.add(barycentre);

		// Afficher le schéma
		System.out.println("Le schéma est composé de : ");
		for (ElemSchema elem : schema) {
			elem.afficher();
			System.out.println();
		}

		// Créer l'écran d'affichage
		Ecran ecran = new Ecran("ExempleSchemaTab", 600, 400, 20);
		ecran.dessinerAxes();

		// Dessiner le schéma sur l'écran graphique
		for (ElemSchema elem : schema) {
			elem.dessiner(ecran);
		}

		// Translater le schéma
		System.out.println("Translater le schéma de (4, -3) : ");
		for (ElemSchema elem : schema) {
			elem.translater(4, -3);
		}

		// Afficher le schéma
		System.out.println("Le schéma est composé de : ");
		for (ElemSchema elem : schema) {
			elem.afficher();
			System.out.println();
		}

		// Dessiner le schéma sur l'écran graphique
		for (ElemSchema elem : schema) {
			elem.dessiner(ecran);
		}

		// Forcer l'affichage du schéma (au cas où...)
		ecran.rafraichir();
	}

}
