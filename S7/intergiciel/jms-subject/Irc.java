import java.awt.Button;
import java.awt.Color;
import java.awt.FlowLayout;
import java.awt.Frame;
import java.awt.TextArea;
import java.awt.TextField;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import javax.jms.*;
import org.apache.activemq.ActiveMQConnection;
import org.apache.activemq.ActiveMQConnectionFactory;

public class Irc {
    public static TextArea text;
    public static TextField data;
    public static Frame frame;

    public static String url = ActiveMQConnection.DEFAULT_BROKER_URL;
    public static String subject = "MyTopic";

    public static ConnectionFactory connectionFactory;
    public static Connection connection;
    public static Session session;
    public static MessageConsumer consumer;
    public static MessageProducer producer;
    public static Topic topic;

    public static void main(String argv[]) {

        if (argv.length != 1) {
            System.out.println("Usage: java Irc <name>");
            return;
        }
        String myName = argv[0];

        // Create GUI
        frame = new Frame();
        frame.setLayout(new FlowLayout());

        text = new TextArea(10, 55);
        text.setEditable(false);
        text.setForeground(Color.red);
        frame.add(text);

        data = new TextField(55);
        frame.add(data);

        Button write_button = new Button("write");
        write_button.addActionListener(new writeListener());
        frame.add(write_button);

        Button connect_button = new Button("connect");
        connect_button.addActionListener(new connectListener(myName));
        frame.add(connect_button);

        Button who_button = new Button("who");
        who_button.addActionListener(new whoListener());
        frame.add(who_button);

        Button leave_button = new Button("leave");
        leave_button.addActionListener(new leaveListener());
        frame.add(leave_button);

        frame.setSize(470, 300);
        text.setBackground(Color.black);
        frame.setVisible(true);
    }

    public static void print(String msg) {
        try {
            text.append(msg + "\n");
        } catch (Exception ex) {
            ex.printStackTrace();
        }
    }

    // Action for "write" button
    static class writeListener implements ActionListener {
        public void actionPerformed(ActionEvent ae) {
            try {
                String message = data.getText();
                if (message != null && !message.trim().isEmpty()) {
                    TextMessage textMessage = session.createTextMessage(message);
                    producer.send(textMessage);
                    print("[You]: " + message);
                    data.setText("");
                }
            } catch (Exception ex) {
                ex.printStackTrace();
            }
        }
    }

    // Action for "connect" button
    static class connectListener implements ActionListener {
        private String name;

        connectListener(String name) {
            this.name = name;
        }

        public void actionPerformed(ActionEvent ae) {
            try {
                connectionFactory = new ActiveMQConnectionFactory(url);
                connection = connectionFactory.createConnection();
                connection.start();

                session = connection.createSession(false, Session.AUTO_ACKNOWLEDGE);
                topic = session.createTopic(subject);

                producer = session.createProducer(topic);
                consumer = session.createConsumer(topic);

                consumer.setMessageListener(new MessageListener() {
                    public void onMessage(Message msg) {
                        try {
                            if (msg instanceof TextMessage) {
                                String textMessage = ((TextMessage) msg).getText();
                                print(textMessage);
                            }
                        } catch (Exception ex) {
                            ex.printStackTrace();
                        }
                    }
                });

                print("Connected as " + name);
            } catch (Exception ex) {
                ex.printStackTrace();
            }
        }
    }

    // Action for "who" button
    static class whoListener implements ActionListener {
        public void actionPerformed(ActionEvent ae) {
            try {
                print("Participants functionality not implemented yet.");
            } catch (Exception ex) {
                ex.printStackTrace();
            }
        }
    }

    // Action for "leave" button
    static class leaveListener implements ActionListener {
        public void actionPerformed(ActionEvent ae) {
            try {
                if (connection != null) {
                    connection.close();
                    print("Disconnected from the chat.");
                }
            } catch (Exception ex) {
                ex.printStackTrace();
            }
        }
    }
}
