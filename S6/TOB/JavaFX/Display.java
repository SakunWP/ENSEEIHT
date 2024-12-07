import javafx.application.Application;
import javafx.scene.Group;
import javafx.scene.PerspectiveCamera;
import javafx.scene.Scene;
import javafx.scene.paint.Color;
import javafx.scene.paint.PhongMaterial;
import javafx.scene.shape.MeshView;
import javafx.scene.shape.TriangleMesh;
import javafx.scene.transform.Rotate;
import javafx.scene.transform.Translate;
import javafx.stage.Stage;

import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

public class Display extends Application {

    @Override
    public void start(Stage primaryStage) throws Exception {
        String filePath = "objet.obj";  // Remplacez par le chemin vers votre fichier .obj
        MeshView meshView = loadObj(filePath);

        if (meshView == null) {
            System.err.println("Le modèle ne contient pas de maillage.");
            return;
        }

        Group root = new Group();
        root.getChildren().add(meshView);

        PerspectiveCamera camera = new PerspectiveCamera(true);
        camera.getTransforms().addAll(
                new Rotate(-20, Rotate.Y_AXIS),
                new Rotate(-20, Rotate.X_AXIS),
                new Translate(0, 0, -500)
        );

        Scene scene = new Scene(root, 800, 600, true);
        scene.setFill(Color.SKYBLUE);
        scene.setCamera(camera);

        primaryStage.setTitle("OBJ Viewer");
        primaryStage.setScene(scene);
        primaryStage.show();
    }

    public static void main(String[] args) {
        launch(args);
    }

    private MeshView loadObj(String filePath) {
        List<float[]> vertices = new ArrayList<>();
        List<int[]> faces = new ArrayList<>();

        try (BufferedReader br = new BufferedReader(new FileReader(filePath))) {
            String line;
            while ((line = br.readLine()) != null) {
                if (line.startsWith("v ")) {
                    String[] parts = line.split("\\s+");
                    float x = Float.parseFloat(parts[1]);
                    float y = Float.parseFloat(parts[2]);
                    float z = Float.parseFloat(parts[3]);
                    vertices.add(new float[]{x, y, z});
                } else if (line.startsWith("f ")) {
                    String[] parts = line.split("\\s+");
                    int v1 = Integer.parseInt(parts[1].split("/")[0]) - 1;
                    int v2 = Integer.parseInt(parts[2].split("/")[0]) - 1;
                    int v3 = Integer.parseInt(parts[3].split("/")[0]) - 1;
                    faces.add(new int[]{v1, v2, v3});
                }
            }
        } catch (IOException e) {
            e.printStackTrace();
            return null;
        }

        if (vertices.isEmpty() || faces.isEmpty()) {
            return null;
        }

        float[] meshVertices = new float[vertices.size() * 3];
        for (int i = 0; i < vertices.size(); i++) {
            float[] vertex = vertices.get(i);
            meshVertices[i * 3] = vertex[0];
            meshVertices[i * 3 + 1] = vertex[1];
            meshVertices[i * 3 + 2] = vertex[2];
        }

        int[] meshFaces = new int[faces.size() * 6]; // chaque face a 3 sommets avec un index pour chaque sommet
        for (int i = 0; i < faces.size(); i++) {
            int[] face = faces.get(i);
            meshFaces[i * 6] = face[0];
            meshFaces[i * 6 + 1] = 0;
            meshFaces[i * 6 + 2] = face[1];
            meshFaces[i * 6 + 3] = 0;
            meshFaces[i * 6 + 4] = face[2];
            meshFaces[i * 6 + 5] = 0;
        }

        TriangleMesh mesh = new TriangleMesh();
        mesh.getPoints().addAll(meshVertices);
        mesh.getFaces().addAll(meshFaces);

        MeshView meshView = new MeshView(mesh);
        PhongMaterial material = new PhongMaterial();
        material.setDiffuseColor(Color.RED); // Couleur du matériau
        meshView.setMaterial(material);

        return meshView;
    }
}
