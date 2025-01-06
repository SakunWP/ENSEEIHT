import java.rmi.RemoteException;
import java.rmi.server.UnicastRemoteObject;

public class RRecordImpl extends UnicastRemoteObject implements RRecord {

    private String name;
    private String email;

    // Constructor
    public RRecordImpl(SRecord sRecord) throws RemoteException {
        super();
        this.name = sRecord.getName();
        this.email = sRecord.getEmail();
    }

    // Getter for name
    @Override
    public String getName() throws RemoteException {
        return name;
    }

    // Getter for email
    @Override
    public String getEmail() throws RemoteException {
        return email;
    }
}
