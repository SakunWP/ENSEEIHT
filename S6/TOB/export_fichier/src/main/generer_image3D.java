import java.io.BufferedWriter;
import java.io.FileWriter;
import java.io.IOException;
public class generer_image3D {
    public static void main(String[] args) {
        // Nom du fichier OBJ de sortie
        String fileName = "objet.obj";

        try (BufferedWriter writer = new BufferedWriter(new FileWriter(fileName))) {
            // Écriture des vertices
            writer.write("v 1.0 1.0 1.0\n"); // vertex 1
            writer.write("v -1.0 1.0 1.0\n"); // vertex 2
            writer.write("v 1.0 -1.0 1.0\n"); // vertex 3
            writer.write("v -1.0 -1.0 1.0\n"); // vertex 4

            // Écriture des faces (dans cet exemple, un simple quadrilatère)
            writer.write("f 1 2 3 4\n"); // face constituée des vertices 1, 2, 3 et 4

            System.out.println("Fichier OBJ généré avec succès !");
        } catch (IOException e) {
            System.err.println("Erreur lors de la génération du fichier OBJ : " + e.getMessage());
        }
    }
}
