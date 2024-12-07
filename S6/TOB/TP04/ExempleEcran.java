
import afficheur.Ecran;
import java.awt.Color;

/**
  * Exemple d'utilisation de la classe Ecran.
  */
class ExempleEcran {

	public static void main(String[] args) {
		// Construire un écran
		Ecran ExempleEcran = new Ecran("ExampleEcran",250,400,15);

		// Dessiner un point vert de coordonnées (1, 2)
		ExempleEcran.dessinerPoint(1,2,Color.green);

		// Dessiner un segment rouge d'extrémités (6, 2) et (11, 9)
		ExempleEcran.dessinerLigne(6,2,11,9,Color.RED);

		// Dessiner un cercle jaune de centre (4, 3) et rayon 2.5
		ExempleEcran.dessinerCercle(4,4,2.5,Color.yellow);

		// Dessiner le texte "Premier dessin" en bleu à la position (1, -2)
		ExempleEcran.dessinerTexte(1,-2,"Premier Texte",Color.BLUE);
	}

}
