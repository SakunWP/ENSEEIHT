public class OccupeException extends Exception{
    public OccupeException() {
        super("le creneau est occupée");
    }

    public OccupeException( String message){
        super (message);
    }
}
