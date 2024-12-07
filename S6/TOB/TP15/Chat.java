import java.util.List;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Iterator;
import java.util.Observable;
import java.util.Observer;

public class Chat extends Observable implements Iterable<Message> {

	// ATTRIBUTS

	private List<Message> messages;


	public Chat() {
		this.messages = new ArrayList<Message>();
	}


	public void inscrire(Observer obs) {
		this.addObserver(obs);
	}

	public void ajouter(Message m) {
		this.messages.add(m);
		this.setChanged();
		this.notifyObservers(m);
	}

	@Override
	public Iterator<Message> iterator() {
		return this.messages.iterator();
	}

}