#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <unistd.h>
/*
#define BUFSIZE 1024 // Taille du tampon mémoire

int main(int argc, char *argv[]) {
    if (argc != 3) {
        printf(stderr, "Usage: %s source destination\n", argv[0]);
        exit(EXIT_FAILURE);
    }

    int source = open(argv[1], O_RDONLY);
    if (source == -1) {
        perror("Erreur lors de l'ouverture du fichier source");
        exit(EXIT_FAILURE);
    }

    int destination = open(argv[2], O_WRONLY | O_CREAT | O_TRUNC, S_IRUSR | S_IWUSR);
    if (destination == -1) {
        perror("Erreur lors de l'ouverture du fichier destination");
        close(source);// Fermeture du fichier source car l'ouverture du fichier destination a échoué
        exit(EXIT_FAILURE);
    }

    char buffer[BUFSIZE];
    ssize_t bytes_read; // demander au prof ça fait é fois que je vois ssize_t

    while ((bytes_read = read(source, buffer, BUFSIZE)) > 0) {
        // Vérification des erreurs de lecture du fichier source (bizarre des fois ça marche et des fois non)
        if (write(destination, buffer, bytes_read) != bytes_read) { // Écriture des données dans le fichier destination
            perror("Erreur lors de l'écriture dans le fichier destination");
            close(source);
            close(destination);
            exit(EXIT_FAILURE);
        }
    }

    close(source);
    close(destination);

    printf("Copie terminée avec succès.\n");

    return EXIT_SUCCESS;
}
*/