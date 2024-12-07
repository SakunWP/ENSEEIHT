package allumettes;

/** Lance une partie des 13 allumettes en fonction des arguments fournis
 * sur la ligne de commande.
 * @author	Xavier Crégut
 * @version	$Revision: 1.5 $
 */
public class Jouer {

	/** Lancer une partie. En argument sont donnés les deux joueurs sous
	 * la forme nom@stratégie.
	 * @param args la description des deux joueurs
	 */
	public static void main(String[] args) {
		try {
			verifierNombreArguments(args);
			play(args);

			//System.out.println("\n\tà faire !\n");

		} catch (ConfigurationException e) {
			System.out.println();
			System.out.println("Erreur : " + e.getMessage());
			afficherUsage();
			System.exit(1);
		}
	}

	private static void verifierNombreArguments(String[] args) {
		final int nbJoueurs = 2;
		if (args.length < nbJoueurs) {
			throw new ConfigurationException("Trop peu d'arguments : "
					+ args.length);
		}
		if (args.length > nbJoueurs + 1) {
			throw new ConfigurationException("Trop d'arguments : "
					+ args.length);
		}
	}

	/** Afficher des indications sur la manière d'exécuter cette classe. */
	public static void afficherUsage() {
		System.out.println("\n" + "Usage :"
				+ "\n\t" + "java allumettes.Jouer joueur1 joueur2"
				+ "\n\t\t" + "joueur est de la forme nom@stratégie"
				+ "\n\t\t" + "strategie = naif | rapide | expert | humain | tricheur"
				+ "\n"
				+ "\n\t" + "Exemple :"
				+ "\n\t" + "	java allumettes.Jouer Xavier@humain "
					   + "Ordinateur@naif"
				+ "\n"
				);
	}

	private static Joueur identifier(String joueur) throws ConfigurationException {
		try {
			String[] player = joueur.split("@");
			Strategie strat = identStrat(player[0], player[1]);
			return new Joueur(player[0], strat);
		} catch (IndexOutOfBoundsException e) {
			throw new ConfigurationException("Absence de @");
		}
	}

	private static Strategie identStrat(String nom, String strat) {
		Strategie strategie;

		switch (strat) {
			case "humain":
				strategie = new StrategieHumaine(nom);
				break;
			case "expert":
				strategie = new StrategieExperte();
				break;
			case "rapide":
				strategie = new StrategieRapide();
				break;
			case "tricheur":
				strategie = new StrategieTriche();
				break;
			case "naif":
				strategie = new StrategieNaif();
				break;
			default:
				throw new ConfigurationException("Aucune stratégie ne correspond");
		}

		return strategie;
	}


	//public static void play(String[] arguments){
		//Joueur j1 = identifier( arguments[0] );
		//Joueur j2 = identifier( arguments[1] );
		//Arbitre arbitre = new Arbitre(j1,j2);
		//JeuClassique jeu = new JeuClassique();

		//if (arguments.length == 2) {
			//arbitre.arbitrer(jeu);
		//} else if (arguments.length == 3) {
			//if (arguments[0] == "-confiant") {
				//arbitre.arbitreConfiant(jeu);
			//} else {
				//throw new ConfigurationException("Le premier argument est invalide");
			//}
		//}
	//}

	public static void play(String[] arguments) {
		JeuClassique jeu = new JeuClassique();
		Arbitre arbitre;
		Joueur j1;
		Joueur j2;
		if (arguments.length == 3) {
			j1 = identifier(arguments[1]);
			j2 = identifier(arguments[2]);
			arbitre = new Arbitre(j1, j2);
			if (arguments[0].equals("-confiant")) {
				arbitre.setConfiant();
				arbitre.arbitrer(jeu);
			} else {
				throw new ConfigurationException("Le premier argument est invalide");
			}
		} else if (arguments.length == 2) {
			j1 = identifier(arguments[0]);
			j2 = identifier(arguments[1]);
			arbitre = new Arbitre(j1, j2);
			arbitre.arbitrer(jeu);
		}
	}

}
