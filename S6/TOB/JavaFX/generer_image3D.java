import java.io.BufferedWriter;
import java.io.FileWriter;
import java.io.IOException;
public class generer_image3D {
    public static void main(String[] args) {
        //creer3D(args[0]);
        creer3D("lol", 1,2,3);
    }

    public static void creer3D(String nom, double x, double y, double z){
        // Nom du fichier OBJ de sortie
        String nomFichier = nom + ".obj";

        try (BufferedWriter writer = new BufferedWriter(new FileWriter(nomFichier))) {
            // trucs mis au hasard pour génerer quelque chose (le writer crée
            // le fichier et edite le .obj
            /*writer.write("v 1.0 1.0 1.0\n");
            writer.write("v -1.0 1.0 1.0\n");
            writer.write("v 1.0 -1.0 1.0\n");
            writer.write("v -1.0 -1.0 1.0\n");

            writer.write("f 1 2 3 4\n"); // face constituée des vertices 1, 2, 3 et 4*/
            writer.write(String.format("v %.6f %.6f %.6f\n", x, y, z));

            System.out.println("Fichier OBJ généré avec succès !");
        } catch (IOException e) {
            System.err.println("Erreur lors de la génération du fichier OBJ : " + e.getMessage());
        }

    }
}
