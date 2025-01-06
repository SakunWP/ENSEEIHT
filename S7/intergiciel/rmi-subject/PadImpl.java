import java.rmi.*;
import java.rmi.server.UnicastRemoteObject;
import java.util.HashMap;
import java.util.Hashtable;
import java.util.Map;

public class PadImpl extends UnicastRemoteObject implements Pad{

    private Map<String, SRecord> records; //stck les noms (String) et les mails (SRecord)
    private String otherServer;

    // Constructor
    public PadImpl(String name, String otherServer) throws RemoteException {
        super();
        this.records = new HashMap<>();
        this.otherServer = otherServer;

        try {
            Naming.bind(name, this);
            System.out.println("lalalala: " + name);
        } catch (Exception e) {
            System.err.println("Error dans bind: " + e.getMessage());
            e.printStackTrace();
        }
    }


    public void add(SRecord sr) throws RemoteException{
        records.put(sr.getName(), sr);
        System.out.println("ajouter: " + sr.getName());
    }

    public RRecord consult(String name, boolean forward) throws RemoteException  {
        SRecord sr = records.get(name);
        if (sr != null) {
            System.out.println("pas trouvé localement: " + name);
            return new RRecordImpl(sr);
        } else if (forward) {
            System.out.println("pas trouvé ici, on regarde dans: " + otherServer);
            try {
                Pad otherPad = (Pad) Naming.lookup(otherServer);
                return otherPad.consult(name, false); //on arrête de forward
            } catch (Exception e) {
                System.err.println("erreur: " + e.getMessage());
                e.printStackTrace();
            }
        }
        System.out.println("pas trouvé: " + name);
        return null;
        
    }

}
