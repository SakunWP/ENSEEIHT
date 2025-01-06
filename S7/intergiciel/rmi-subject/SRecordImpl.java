import java.io.Serializable;

public class SRecordImpl implements SRecord, Serializable {

    private static final long serialVersionUID = 1L;
    private String name;
    private String email;

    // Constructor
    public SRecordImpl(String name, String email) {
        this.name = name;
        this.email = email;
    }

    // Getter for name
    @Override
    public String getName() {
        return name;
    }

    // Getter for email
    @Override
    public String getEmail() {
        return email;
    }
}