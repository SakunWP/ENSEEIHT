import java.util.Objects;
import java.util.Observable;
import java.util.Observer;

import javax.swing.*;
import java.awt.*;

public class VueChat extends JPanel implements Observer {

    private JTextArea chatTexte;

    public VueChat (Chat chat){
        chat.addObserver(this);
        configurerVue();
    }

    void configurerVue(){
        chatTexte = new JTextArea(10,40);
        chatTexte.setEditable(false);
        this.add(chatTexte, BorderLayout.CENTER);
    }

    public void update (Observable o, Object arg){
        if (! (arg instanceof Message)){
            return ;
        }
        chatTexte.append(arg.toString() + "\n");
    }


}

// MÉTHODES
