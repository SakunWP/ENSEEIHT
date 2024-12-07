#include <stdio.h>
#include <stdlib.h>
#include "readcmd.h"
#include <stdbool.h>
#include <string.h>
#include <unistd.h>
#include <sys/wait.h>
#include <signal.h>
#include <sys/fcntl.h>

void affichePrompt() {
    printf("> ");
}

void traitementSIGCHLD(int S) {
    int status;
    pid_t pid;
    while ((pid = waitpid(-1, &status, WNOHANG|WUNTRACED|WCONTINUED)) > 0) {
        if (WIFEXITED(status)) {
            printf("Le processus fils avec PID %d s'est terminé avec le code de sortie %d.\n", pid, status);
        } 
        else if (WIFSIGNALED(status)){
            printf("Le processus fils avec PID %d s'est terminé suite à un signal %d.\n", pid, WTERMSIG(status));
        } else if (WIFSTOPPED(status)) {
            printf("Le processus fils avec PID %d a été suspendu.\n", pid);
        } else if (WIFCONTINUED(status)) {
            printf("Le processus fils avec PID %d a été repris.\n", pid);
        }
    }
    /*int status;
    pid_t pid = waitpid(-1, &status, WNOHANG);
    if (pid == -1) {
        printf("Erreur de terminaison du fils\n");
    }
    if (WIFEXITED(status)) {
        printf("Terminaison du fils de pid : %d\n", pid);
    }
    if (S == SIGCHLD) {
        if (WIFSTOPPED(status)) {
            printf("Suspension du fils stop de pid : %d\n", pid);
        }
        if (WIFCONTINUED(status)) {
            printf("Reprise du fils continue de pid : %d\n", pid);
        }
        if (WIFSIGNALED(status)) {
            printf("Envoi d'un signal vers le fils de pid : %d\n", pid);
        }
    }*/
}

void traitementSIGINT(int S) {
    if (S == SIGINT) {
        printf("Ctrl + C\n");
    }
}

void traitementSIGTSTP(int S) {
    if (S == SIGTSTP) {
        printf("Ctrl + Z\n");
    }
    affichePrompt();
}

int set_signal(int sig, void (*traitement)(int)) {
    if (signal(sig, traitement) == SIG_ERR) {
        perror("Erreur lors de la définition du signal");
        return -1;
    }
    return 0;
}

void execute_command(char **cmd, struct cmdline *commande) {
    if (commande->in != NULL) {
        int fd = open(commande->in, O_RDONLY);
        if (fd == -1) {
            perror("Erreur lors de l'ouverture du fichier en lecture");
            exit(EXIT_FAILURE);
        }
        dup2(fd, STDIN_FILENO);
        close(fd);
    }
    if (commande->out != NULL) {
        int fd = open(commande->out, O_WRONLY | O_CREAT | O_TRUNC, S_IRUSR | S_IWUSR);
        if (fd == -1) {
            perror("Erreur lors de l'ouverture du fichier en écriture");
            exit(EXIT_FAILURE);
        }
        dup2(fd, STDOUT_FILENO);
        close(fd);
    }
    execvp(cmd[0], cmd);
    perror("Erreur lors de l'exécution de la commande");
    exit(EXIT_FAILURE);
}

void execute_pipeline(struct cmdline *commande) {
    int num_cmds = 0;
    while (commande->seq[num_cmds] != NULL){
        num_cmds++;
    } 
    
    int pipefds[2 * (num_cmds - 1)];
    for (int i = 0; i < (num_cmds - 1); i++) {
        if (pipe(pipefds + i * 2) == -1) {
            perror("pipe");
            exit(EXIT_FAILURE);
        }
    }
    
    for (int i = 0; i < num_cmds; i++) {
        pid_t pid = fork();
        if (pid == -1) {
            perror("fork");
            exit(EXIT_FAILURE);
        }
        if (pid == 0) {
            if (i > 0) {
                if (dup2(pipefds[(i - 1) * 2], 0) == -1) {
                    perror("dup2");
                    exit(EXIT_FAILURE);
                }
            }
            if (i < num_cmds - 1) {
                if (dup2(pipefds[i * 2 + 1], 1) == -1) {
                    perror("dup2");
                    exit(EXIT_FAILURE);
                }
            }
            for (int k = 0; k < 2 * (num_cmds - 1); k++) {
                close(pipefds[k]);
            }
            execute_command(commande->seq[i], commande);
        }
    }
    for (int i = 0; i < 2 * (num_cmds - 1); i++) {
        close(pipefds[i]);
    }
    for (int i = 0; i < num_cmds; i++) {
        wait(NULL);
    }
}

int main(void) {
    struct sigaction action;
    action.sa_handler = traitementSIGCHLD;
    sigemptyset(&action.sa_mask);
    action.sa_flags = SA_RESTART;
    sigaction(SIGCHLD, &action, NULL);

    set_signal(SIGINT, traitementSIGINT);
    set_signal(SIGTSTP, traitementSIGTSTP);

    bool fini = false;

    while (!fini) {
        affichePrompt();
        struct cmdline *commande = readcmd();

        if (commande == NULL) {
            perror("erreur lecture commande \n");
            exit(EXIT_FAILURE);
        } else {
            if (commande->err) {
                printf("erreur saisie de la commande : %s\n", commande->err);
            } else {
                if (commande->seq[1] == NULL) { // Si il n'y a qu'une seule commande
                    char **cmd = commande->seq[0];
                    if (cmd[0]) {
                        if (strcmp(cmd[0], "exit") == 0) {
                            fini = true;
                            printf("Au revoir ...\n");
                        } else {
                            pid_t pid = fork();
                            if (pid < 0) {
                                perror("Erreur fork\n");
                                exit(EXIT_FAILURE);
                            } else if (pid == 0) {
                                set_signal(SIGINT, SIG_DFL);
                                set_signal(SIGTSTP, SIG_DFL);
                                if (commande->backgrounded != NULL) {
                                    setpgrp();
                                }
                                execute_command(cmd, commande);
                            } else {
                                if (commande->backgrounded == NULL) {
                                    waitpid(pid, NULL, 0);
                                    //pause();
                                    //wait(NULL);
                                }
                            }
                        }
                    }
                } else { // Si il y a des tubes à gérer
                    execute_pipeline(commande);
                }
            }
        }
    }
    return EXIT_SUCCESS;
}
