/**
 * AgendaAbstrait factorise la définition du nom et de l'accesseur associé.
 */
public abstract class AgendaAbstrait extends ObjetNomme implements Agenda {

	/**
	 * Initialiser le nom de l'agenda.
	 *
	 * @param nom le nom de l'agenda
	 * @throws IllegalArgumentException si nom n'a pas au moins un caractère
	 */
	public AgendaAbstrait(String nom) {
		super(nom);
	}

	public void verifierCrenauValide(int creneau) throws IllegalArgumentException{
		if (creneau<Agenda.CRENEAU_MIN || creneau>Agenda.CRENEAU_MAX){
			throw new CreneauInvalideException();
		}
	}

}
