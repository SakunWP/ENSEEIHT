import java.net.*;
import java.util.Random;
import java.io.*;

public class LoadBalancer extends Thread {
    static String hosts[]= {"LocalHost","LocalHost"};
    static int ports[] = {8081,8082};
    static int nbhosts = 2;
    static Random rand = new Random();
    Socket sockClient;

    public LoadBalancer (Socket sock){
        this.sockClient= sock;
    }

    public static void main (String[] args) throws NumberFormatException, IOException{
        ServerSocket server = new ServerSocket(Integer.parseInt(args[0]));
        while (true){
            Thread t = new LoadBalancer(server.accept());
            t.start();
            System.out.println("new connection");
        } 
    }

    public void run(){
        int index_server = rand.nextInt(nbhosts);
        try {
            Socket socks = new Socket(hosts[index_server],ports[index_server]);
            InputStream Client_in = sockClient.getInputStream();
            byte buffer [] = new byte [1024];
            int nb_lus = Client_in.read(buffer);
            OutputStream s_out = socks.getOutputStream();
            s_out.write(buffer,0,nb_lus);
            InputStream s_in = socks.getInputStream();
            byte buffer2 []= new byte [1024];
            nb_lus = s_in.read(buffer2);
            OutputStream Client_out = sockClient.getOutputStream();
            Client_out.write(buffer2,0,nb_lus);
            Client_in.close();
            s_out.close();
            s_in.close();
            Client_out.close();
        } catch (Exception e) {System.out.println('e');}
    }
}

