/* ------------------------------------------------------- 
		Les packages Java qui doivent etre importes.
*/
import java.awt.*;
import java.awt.event.*;
import java.rmi.*;
import javax.swing.*;



/* ------------------------------------------------------- 
		Implementation de l'application
*/

public class GUI extends JFrame {
	TextField name, email;
	Choice pads;
	Label message;
	public GUI() {
		setSize(300,200);
		setLayout(new GridLayout(6,2));
		add(new Label("  Name : "));
		name = new TextField(30);
		add(name);
		add(new Label("  Email : "));
		email = new TextField(30);
		add(email);
		add(new Label("  Pad : "));
		pads = new Choice();
		pads.addItem("Pad1");
		pads.addItem("Pad2");
		add(pads);
		add(new Label(""));
		add(new Label(""));
		Button Abutton = new Button("add");
		Abutton.addActionListener(new AButtonAction());
		add(Abutton);
		Button Cbutton = new Button("consult");
		Cbutton.addActionListener(new CButtonAction());
		add(Cbutton);
		message = new Label();
		add(message);
	}

	class CButtonAction implements ActionListener {
		public void actionPerformed(ActionEvent ae) {
			String n, c;
			n = name.getText();
			c = pads.getSelectedItem();
			message.setText("consult("+n+","+c+")        ");
			// to be completed / the user clicked on the consult button
		}
	}
	class AButtonAction implements ActionListener {
		public void actionPerformed(ActionEvent ae) {
			String n, e, c;
			n = name.getText();
			e = email.getText();
			c = pads.getSelectedItem();
			message.setText("add("+n+","+e+","+c+")");
			// to be completed / the user clicked on the add button
		}
	}
	
	public static void main(String args[]) {
		GUI s = new GUI();
        s.setSize(400,200);
        s.setVisible(true);
	}
}


