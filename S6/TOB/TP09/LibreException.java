public class LibreException extends Exception {
    public LibreException(){
        super("creneau pas libre");
    }

    public LibreException(String message){
        super(message);
    }
}
